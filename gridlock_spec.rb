require "./gridlock"

RSpec.describe GridLock do

  it "has symbols" do
    expect(GridLock::Symbols).to include([GridLock::CROSS, GridLock::SQUARE, GridLock::CIRCLE].sample)
  end
  it "has pieces with symbols" do
    expect(GridLock::Piece::All).to include(GridLock::Piece::A)
  end

  it "has a default board" do
    expect(GridLock::Board).to be_a(Array)
  end

  context "rotate" do
    let(:piece) { GridLock::Piece::A }

    let(:rotated_1) { GridLock::Piece.rotate(piece)     } # 90º
    let(:rotated_2) { GridLock::Piece.rotate(rotated_1) } # 180º
    let(:rotated_3) { GridLock::Piece.rotate(rotated_2) } # 270º
    let(:rotated_4) { GridLock::Piece.rotate(rotated_3) } # 360º -> original piece

    it("original") { expect(piece).to eq( [GridLock::CROSS, GridLock::CIRCLE]) }

    context "one dimension" do

      it "90º" do
        expect(rotated_1).to eq( [
          [GridLock::CROSS, nil],
          [GridLock::CIRCLE, nil]
        ])
      end 

      it("180º") { expect(rotated_2).to eq( [ GridLock::CIRCLE, GridLock::CROSS ] ) }

      it "270º" do
        expect(rotated_3).to eq( [
          [GridLock::CIRCLE, nil],
          [GridLock::CROSS, nil ]
        ])
      end
      it("360º is eq 0º"){  expect(rotated_4).to eq( piece ) }
    end

    context "two dimensions" do
      let(:piece) { GridLock::Piece::H }

      it "original" do
        expect(piece).to eq( [
          [GridLock::CROSS, GridLock::CIRCLE],
          GridLock::SQUARE
        ])
      end

      it "90º" do
        expect(rotated_1).to eq( [
          [GridLock::SQUARE, GridLock::CROSS],
          [             nil, GridLock::CIRCLE],
        ])
      end

      it "180º" do
        expect(rotated_2).to eq( [
          [             nil, GridLock::SQUARE],
          [ GridLock::CIRCLE, GridLock::CROSS],
        ])
      end

      it "270º" do
        expect(rotated_4).to eq( [
          [GridLock::CROSS, GridLock::CIRCLE],
          [GridLock::SQUARE, nil]
        ])
      end
    end
  end

  context 'game' do
    let(:game) { GridLock::Game.new }
    let(:cross_circle) {  [GridLock::CROSS, GridLock::CIRCLE] }
    let(:rotated_cross_circle) {GridLock::Piece.rotate(cross_circle)}
    let(:square_cross_circle) { [[GridLock::SQUARE, GridLock::CROSS], [GridLock::CIRCLE]] }
    let(:rotated_square_cross_circle) { GridLock::Piece.rotate(square_cross_circle) }

    it "print" do
      expect { game.print_game(false) }.to output( %{
▢ ✚ ◯ ◯
◯ ▢ ▢ ✚
✚ ✚ ◯ ✚
✚ ▢ ◯ ▢
✚ ▢ ✚ ✚
◯ ▢ ◯ ◯
◯ ◯ ▢ ▢
}).to_stdout
    end

    it "print piece" do
      expect {puts ; game.print_piece([["◯", "✚"], [nil, "▢"]]) }.to output( %{
◯ ✚
  ▢
}).to_stdout
      expect { puts ; game.print_piece([[nil, "◯"], ["✚", "▢"]]) }.to output( %{
  ◯
✚ ▢
}).to_stdout
      expect { puts ; game.print_piece(["✚", "▢"]) }.to output( %{
✚ ▢

}).to_stdout
    end

    context ".match?" do
      it { expect(game.match?(cross_circle, 0, 0)).to be_falsy  }
      it { expect(game.match?(cross_circle, 0, 1)).to be_truthy }
      it { expect(game.match?(square_cross_circle, 0, 0)).to be_truthy }
      it { expect(game.match?(square_cross_circle, 0, 1)).to be_falsy}
      it { expect(game.match?(rotated_cross_circle, 4, 0)).to be_truthy}
      it { expect(game.match?(rotated_cross_circle, 4, 2)).to be_truthy}
      it { expect(game.match?(rotated_cross_circle, 4, 1)).to be_falsy}
      it { expect(game.match?(rotated_square_cross_circle, 1, 0)).to be_truthy}
      it { expect(game.match?([["◯", "◯"], "▢"], 5, 2)).to be_truthy}
    end

    context ".each_symbol_of" do
      specify { expect { |b| game.each_symbol_of(["a","b"], &b) }.to yield_successive_args(["a",0, 0], ["b",0, 1]) }
      specify { expect { |b| game.each_symbol_of([["a",nil],["b",nil]], &b) }.to yield_successive_args(["a",0, 0], ["b", 1, 0]) }
      specify { expect { |b| game.each_symbol_of([["a",nil],["b","c"]], &b) }.to yield_successive_args(["a",0, 0], ["b", 1, 0], ["c", 1, 1]) }
      specify { expect { |b| game.each_symbol_of([["◯", "◯"], "▢"], &b) }.to yield_successive_args(["◯",0, 0],["◯",0, 1],["▢", 1, 0]) }
      specify { expect { |b| game.each_symbol_of([["◯", "◯"], ["▢"]], &b) }.to yield_successive_args(["◯",0, 0],["◯",0, 1],["▢", 1, 0]) }
      specify { expect { |b| game.each_symbol_of([["◯", "◯"], [nil, "▢"]], &b) }.to yield_successive_args(["◯",0, 0],["◯",0, 1],["▢", 1, 1]) }
    end

    context ".fit?" do
      it 'false when filled' do
        game.fill(0,0)
        expect(game.fit?(cross_circle, 0,0)).to be_falsy
      end

      it 'false when symbol does not match on position' do
        expect(game.fit?(cross_circle, 0,2)).to be_falsy
      end

      it 'when spot is free and match the position' do
        expect(game.fit?(cross_circle, 2,1)).to be_truthy
      end
    end

    context "enclosures" do
      before do
        game.fill(0,1)
        game.fill(1,0)
      end

      specify { expect(game.enclosures).to eq([[0,0]]) }
      specify { expect(game.enclosured?(0,0)).to be_truthy }

      context "complex" do
        before do
          game.fill(0,3)
          game.fill(1,2)
          game.fill(2,3)
        end
        specify { game.print_game; expect(game.enclosured?(1,3)).to be_truthy }
        specify { expect(game.enclosured?(2,3)).to be_falsy  }
        specify { expect(game.enclosured?(0,3)).to be_falsy  }
      end

      context "right side" do
        before do
          game.fill(0,3)
          game.fill(1,2)
          game.fill(2,3)
          game.print_game
        end
        specify { expect(game.enclosured?(1,3)).to be_truthy }
      end
    end

    context ".navigate" do
      before do
        game.instance_variable_set("@rows", 2)
        game.instance_variable_set("@cols", 3)
      end
      specify { expect { |b| game.navigate(&b) }
        .to yield_successive_args([0, 0], [0, 1], [0, 2], [1, 0], [1, 1], [1, 2]) }
    end

    context "around" do
      specify { expect(game.around(0,0)).to match_array([[0, 1], [1, 0]]) }
      specify { expect(game.around(1,0)).to match_array([[0, 0], [2, 0], [1, 1]]) }
      specify { expect(game.around(1,1)).to match_array([[0, 1], [1, 0], [1, 2], [2, 1]]) }
      specify { expect(game.around(3,1)).to match_array([[3, 0], [2, 1], [3, 2], [4, 1]]) }
      specify { expect(game.around(5,3)).to match_array([[5, 2], [4, 3], [6, 3]]) }
      specify { expect(game.around(6,2)).to match_array([[6, 1], [5, 2], [6, 3]]) }
      specify { expect(game.around(6,3)).to eq([[6, 2], [5, 3]]) }
      specify { expect(game.around(3,0)).to eq([[2, 0], [3, 1], [4, 0]]) }
    end

    context "put!(piece, row, col)" do
      it "fill piece positions" do
        expect(game.put!(cross_circle, 2,1)).to be_truthy
        expect(game.fit?(cross_circle, 2,1)).to be_falsy
        expect { game.put!(cross_circle, 2,1) }.to raise_error(GridLock::GameError, 'piece: ["✚", "◯"] does not fit on row: 2, col: 1')
      end

      specify do
        expect(game.history).to be_empty
      end

      specify do
        expect{ game.put!(cross_circle, 2,1) }.to change(game.history,:length).from(0).to(1)
      end

      specify do
        game.put!(cross_circle, 2, 1)
        game.print_game
        expect(game.spot_busy?(2,1)).to be_truthy
        expect(game.spot_busy?(2,2)).to be_truthy
        expect(game.history[0]).to match_array([[2,1], [2,2]])
        game.undo
        expect(game.spot_busy?(2,1)).to be_falsy
        expect(game.spot_busy?(2,2)).to be_falsy
        expect(game.history).to be_empty
        expect { game.undo }.to raise_error(GridLock::GameError, 'History empty! Nothing to undo.')
      end
    end
  end
end
