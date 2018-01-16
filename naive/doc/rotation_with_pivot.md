## Rotations

Each piece have 4 valid rotations, and each rotation have
a pivot that is used to try filling the rotated piece in
the board.

    # Rotation:
    #   pivot: Point
    #   cells: [Cell]

    # Example 1
    # .a b  .c a   _.c  .b _
    #  c _   _ b   b a   a c

    piece = Piece.new(2, 'abc')
    piece.rotations[0]
    # => Rotation
    # pivot: Point(x: 0, y: 0)
    # cells: [
    #   Cell(symbol: 'a', point: Point(0, 0)),
    #   Cell(symbol: 'b', point: Point(0, 1)),
    #   Cell(symbol: 'c', point: Point(1, 0)),
    # ]

    piece.rotations[2]
    # => Rotation
    # pivot: Point(x: 0, y: 1)
    # cells: [
    #   Cell(symbol: 'c', point: Point(0,  0)),
    #   Cell(symbol: 'b', point: Point(1, -1)),
    #   Cell(symbol: 'a', point: Point(1,  0)),
    # ]

    # Example 2
    # .a b  .b _   _ _   _.a
    #  _ _   a _  .b a   _ b

    piece = Piece.new(2, 'ab')
    piece.rotations[0]
    # => Rotation
    # pivot: Point(x: 0, y: 0)
    # cells: [
    #   Cell(symbol: 'a', point: Point(0, 0)),
    #   Cell(symbol: 'b', point: Point(0, 1)),
    # ]

    piece.rotations[1]
    # => Rotation
    # pivot: Point(x: 0, y: 1)
    # cells: [
    #   Cell(symbol: 'a', point: Point(0, 0)),
    #   Cell(symbol: 'b', point: Point(1, 0)),
    # ]

## Placing a rotated piece in the board

    board:
      a b b
      c c c

    pieces:
      a b     c c
      c _  ,  b _

    rotations:
     .a b     _.b
      c _  ,  c c
     (r 0)   (r 2)

    placing_steps:
      add first:
        board index: bindex = [0, 0]
          .a b b
           c c c

        cindex = rotations[0].cells_index:
          [a: [0, 0], b: [0, 1], c: [1, 0]]

        cindex.all {|index| board[index + bindex] == rotations[0][index] }

      add second:
        board index: bindex = [0, 2]
          _a_b.b
          _c c c

        cindex = rotations[1].cells_index:
          [b: [0, 0], c: [1, -1], c: [1, 0]]

        cindex.all {|index| board[index + bindex] == rotations[0][index] }

### Solving the 2x2 rotations[1].cells_index

     piece and turn 2:
        \: -1 0 1  | -1 0 1
           ------- | ------
       -1:         |  _ c
        0:    a b  |  b a
        1:    c _  |
           ------- | ------
    pivot:   (0,0) |  (-1,0)

    piece.cells_index:  [a: (0,0), b: (0, 1), c: ( 1,0)]

    turned.cells_index = rotate(piece.cells_index, turns)
    turned.cells_index: [a: (0,0), b: (0,-1), c: (-1,0)]

    result = turned.cells_index - pivot
    result.cells_index: [a: (1,0), b: (1,-1), c: ( 0,0)]

    rotated_piece[index] = piece[index + pivot]

### Solving the 1x2 piece rotations[1].cells_index

     piece and turn 1:
        \: -1 0 1  | -1 0 1
           ------- | ------
       -1:         |    b
        0:    a b  |    a
        1:         |
           ------- | ------
    pivot:   (0,0) |  (-1,0)

    piece.cells_index:  [a: (0,0), b: ( 0,1)]

    turned.cells_index = rotate(piece.cells_index, turns)
    turned.cells_index: [a: (0,0), b: (-1,0)]

    result = turned.cells_index - pivot
    result.cells_index: [a: (1,0), b: (0,0)]

    rotated_piece[index] = piece[index + pivot]
