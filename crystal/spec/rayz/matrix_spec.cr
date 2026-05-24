require "../spec_helper"

describe "Matrix" do
  it "Constructing and inspecting a 4x4 matrix" do
    m = Rayz::Matrix.new([
      [1.0, 2.0, 3.0, 4.0],
      [5.5, 6.5, 7.5, 8.5],
      [9.0, 10.0, 11.0, 12.0],
      [13.5, 14.5, 15.5, 16.5],
    ])
    m[0, 0].should eq(1.0)
    m[0, 3].should eq(4.0)
    m[1, 0].should eq(5.5)
    m[1, 2].should eq(7.5)
    m[2, 2].should eq(11.0)
    m[3, 0].should eq(13.5)
    m[3, 2].should eq(15.5)
  end

  it "A 2x2 matrix ought to be representable" do
    m = Rayz::Matrix.new([
      [-3.0, 5.0],
      [1.0, -2.0],
    ])
    m[0, 0].should eq(-3.0)
    m[0, 1].should eq(5.0)
    m[1, 0].should eq(1.0)
    m[1, 1].should eq(-2.0)
  end

  it "A 3x3 matrix ought to be representable" do
    m = Rayz::Matrix.new([
      [-3.0, 5.0, 0.0],
      [1.0, -2.0, -7.0],
      [0.0, 1.0, 1.0],
    ])
    m[0, 0].should eq(-3.0)
    m[1, 1].should eq(-2.0)
    m[2, 2].should eq(1.0)
  end

  it "Matrix equality with identical matrices" do
    a = Rayz::Matrix.new([
      [1.0, 2.0, 3.0, 4.0],
      [5.0, 6.0, 7.0, 8.0],
      [9.0, 8.0, 7.0, 6.0],
      [5.0, 4.0, 3.0, 2.0],
    ])
    b = Rayz::Matrix.new([
      [1.0, 2.0, 3.0, 4.0],
      [5.0, 6.0, 7.0, 8.0],
      [9.0, 8.0, 7.0, 6.0],
      [5.0, 4.0, 3.0, 2.0],
    ])
    a.should eq(b)
  end

  it "Matrix equality with different matrices" do
    a = Rayz::Matrix.new([
      [1.0, 2.0, 3.0, 4.0],
      [5.0, 6.0, 7.0, 8.0],
      [9.0, 8.0, 7.0, 6.0],
      [5.0, 4.0, 3.0, 2.0],
    ])
    b = Rayz::Matrix.new([
      [2.0, 3.0, 4.0, 5.0],
      [6.0, 7.0, 8.0, 9.0],
      [8.0, 7.0, 6.0, 5.0],
      [4.0, 3.0, 2.0, 1.0],
    ])
    a.should_not eq(b)
  end

  it "Multiplying two matrices" do
    a = Rayz::Matrix.new([
      [1.0, 2.0, 3.0, 4.0],
      [5.0, 6.0, 7.0, 8.0],
      [9.0, 8.0, 7.0, 6.0],
      [5.0, 4.0, 3.0, 2.0],
    ])
    b = Rayz::Matrix.new([
      [-2.0, 1.0, 2.0, 3.0],
      [3.0, 2.0, 1.0, -1.0],
      [4.0, 3.0, 6.0, 5.0],
      [1.0, 2.0, 7.0, 8.0],
    ])
    expected = Rayz::Matrix.new([
      [20.0, 22.0, 50.0, 48.0],
      [44.0, 54.0, 114.0, 108.0],
      [40.0, 58.0, 110.0, 102.0],
      [16.0, 26.0, 46.0, 42.0],
    ])
    (a * b).should eq(expected)
  end

  it "A matrix multiplied by a tuple" do
    a = Rayz::Matrix.new([
      [1.0, 2.0, 3.0, 4.0],
      [2.0, 4.0, 4.0, 2.0],
      [8.0, 6.0, 4.0, 1.0],
      [0.0, 0.0, 0.0, 1.0],
    ])
    b = Rayz::Tuple.new(1.0, 2.0, 3.0, 1.0)
    (a * b).should eq(Rayz::Tuple.new(18.0, 24.0, 33.0, 1.0))
  end

  it "Multiplying a matrix by the identity matrix" do
    a = Rayz::Matrix.new([
      [0.0, 1.0, 2.0, 4.0],
      [1.0, 2.0, 4.0, 8.0],
      [2.0, 4.0, 8.0, 16.0],
      [4.0, 8.0, 16.0, 32.0],
    ])
    (a * Rayz::Matrix.identity).should eq(a)
  end

  it "Multiplying the identity matrix by a tuple" do
    a = Rayz::Tuple.new(1.0, 2.0, 3.0, 4.0)
    (Rayz::Matrix.identity * a).should eq(a)
  end

  it "Transposing a matrix" do
    a = Rayz::Matrix.new([
      [0.0, 9.0, 3.0, 0.0],
      [9.0, 8.0, 0.0, 8.0],
      [1.0, 8.0, 5.0, 3.0],
      [0.0, 0.0, 5.0, 8.0],
    ])
    expected = Rayz::Matrix.new([
      [0.0, 9.0, 1.0, 0.0],
      [9.0, 8.0, 8.0, 0.0],
      [3.0, 0.0, 5.0, 5.0],
      [0.0, 8.0, 3.0, 8.0],
    ])
    a.transpose.should eq(expected)
  end

  it "Transposing the identity matrix" do
    Rayz::Matrix.identity.transpose.should eq(Rayz::Matrix.identity)
  end

  it "Calculating the determinant of a 2x2 matrix" do
    a = Rayz::Matrix.new([
      [1.0, 5.0],
      [-3.0, 2.0],
    ])
    a.determinant.should be_close(17.0, 0.0001)
  end

  it "A submatrix of a 3x3 matrix is a 2x2 matrix" do
    a = Rayz::Matrix.new([
      [1.0, 5.0, 0.0],
      [-3.0, 2.0, 7.0],
      [0.0, 6.0, -3.0],
    ])
    expected = Rayz::Matrix.new([
      [-3.0, 2.0],
      [0.0, 6.0],
    ])
    a.submatrix(0, 2).should eq(expected)
  end

  it "A submatrix of a 4x4 matrix is a 3x3 matrix" do
    a = Rayz::Matrix.new([
      [-6.0, 1.0, 1.0, 6.0],
      [-8.0, 5.0, 8.0, 6.0],
      [-1.0, 0.0, 8.0, 2.0],
      [-7.0, 1.0, -1.0, 1.0],
    ])
    expected = Rayz::Matrix.new([
      [-6.0, 1.0, 6.0],
      [-8.0, 8.0, 6.0],
      [-7.0, -1.0, 1.0],
    ])
    a.submatrix(2, 1).should eq(expected)
  end

  it "Calculating a minor of a 3x3 matrix" do
    a = Rayz::Matrix.new([
      [3.0, 5.0, 0.0],
      [2.0, -1.0, -7.0],
      [6.0, -1.0, 5.0],
    ])
    b = a.submatrix(1, 0)
    b.determinant.should be_close(25.0, 0.0001)
    a.minor(1, 0).should be_close(25.0, 0.0001)
  end

  it "Calculating a cofactor of a 3x3 matrix" do
    a = Rayz::Matrix.new([
      [3.0, 5.0, 0.0],
      [2.0, -1.0, -7.0],
      [6.0, -1.0, 5.0],
    ])
    a.minor(0, 0).should be_close(-12.0, 0.0001)
    a.cofactor(0, 0).should be_close(-12.0, 0.0001)
    a.minor(1, 0).should be_close(25.0, 0.0001)
    a.cofactor(1, 0).should be_close(-25.0, 0.0001)
  end

  it "Calculating the determinant of a 3x3 matrix" do
    a = Rayz::Matrix.new([
      [1.0, 2.0, 6.0],
      [-5.0, 8.0, -4.0],
      [2.0, 6.0, 4.0],
    ])
    a.cofactor(0, 0).should be_close(56.0, 0.0001)
    a.cofactor(0, 1).should be_close(12.0, 0.0001)
    a.cofactor(0, 2).should be_close(-46.0, 0.0001)
    a.determinant.should be_close(-196.0, 0.0001)
  end

  it "Calculating the determinant of a 4x4 matrix" do
    a = Rayz::Matrix.new([
      [-2.0, -8.0, 3.0, 5.0],
      [-3.0, 1.0, 7.0, 3.0],
      [1.0, 2.0, -9.0, 6.0],
      [-6.0, 7.0, 7.0, -9.0],
    ])
    a.cofactor(0, 0).should be_close(690.0, 0.0001)
    a.cofactor(0, 1).should be_close(447.0, 0.0001)
    a.cofactor(0, 2).should be_close(210.0, 0.0001)
    a.cofactor(0, 3).should be_close(51.0, 0.0001)
    a.determinant.should be_close(-4071.0, 0.0001)
  end

  it "Testing an invertible matrix for invertibility" do
    a = Rayz::Matrix.new([
      [6.0, 4.0, 4.0, 4.0],
      [5.0, 5.0, 7.0, 6.0],
      [4.0, -9.0, 3.0, -7.0],
      [9.0, 1.0, 7.0, -6.0],
    ])
    a.determinant.should be_close(-2120.0, 0.0001)
    a.invertible?.should be_true
  end

  it "Testing a noninvertible matrix for invertibility" do
    a = Rayz::Matrix.new([
      [-4.0, 2.0, -2.0, -3.0],
      [9.0, 6.0, 2.0, 6.0],
      [0.0, -5.0, 1.0, -5.0],
      [0.0, 0.0, 0.0, 0.0],
    ])
    a.determinant.should be_close(0.0, 0.0001)
    a.invertible?.should be_false
  end

  it "Calculating the inverse of a matrix" do
    a = Rayz::Matrix.new([
      [-5.0, 2.0, 6.0, -8.0],
      [1.0, -5.0, 1.0, 8.0],
      [7.0, 7.0, -6.0, -7.0],
      [1.0, -3.0, 7.0, 4.0],
    ])
    b = a.inverse
    a.determinant.should be_close(532.0, 0.0001)
    a.cofactor(2, 3).should be_close(-160.0, 0.0001)
    b[3, 2].should be_close(-160.0 / 532.0, 0.0001)
    a.cofactor(3, 2).should be_close(105.0, 0.0001)
    b[2, 3].should be_close(105.0 / 532.0, 0.0001)
    expected = Rayz::Matrix.new([
      [0.21805, 0.45113, 0.24060, -0.04511],
      [-0.80827, -1.45677, -0.44361, 0.52068],
      [-0.07895, -0.22368, -0.05263, 0.19737],
      [-0.52256, -0.81391, -0.30075, 0.30639],
    ])
    b.should eq(expected)
  end

  it "Calculating the inverse of another matrix" do
    a = Rayz::Matrix.new([
      [8.0, -5.0, 9.0, 2.0],
      [7.0, 5.0, 6.0, 1.0],
      [-6.0, 0.0, 9.0, 6.0],
      [-3.0, 0.0, -9.0, -4.0],
    ])
    expected = Rayz::Matrix.new([
      [-0.15385, -0.15385, -0.28205, -0.53846],
      [-0.07692, 0.12308, 0.02564, 0.03077],
      [0.35897, 0.35897, 0.43590, 0.92308],
      [-0.69231, -0.69231, -0.76923, -1.92308],
    ])
    a.inverse.should eq(expected)
  end

  it "Calculating the inverse of a third matrix" do
    a = Rayz::Matrix.new([
      [9.0, 3.0, 0.0, 9.0],
      [-5.0, -2.0, -6.0, -3.0],
      [-4.0, 9.0, 6.0, 4.0],
      [-7.0, 6.0, 6.0, 2.0],
    ])
    expected = Rayz::Matrix.new([
      [-0.04074, -0.07778, 0.14444, -0.22222],
      [-0.07778, 0.03333, 0.36667, -0.33333],
      [-0.02901, -0.14630, -0.10926, 0.12963],
      [0.17778, 0.06667, -0.26667, 0.33333],
    ])
    a.inverse.should eq(expected)
  end

  it "Multiplying a product by its inverse" do
    a = Rayz::Matrix.new([
      [3.0, -9.0, 7.0, 3.0],
      [3.0, -8.0, 2.0, -9.0],
      [-4.0, 4.0, 4.0, 1.0],
      [-6.0, 5.0, -1.0, 1.0],
    ])
    b = Rayz::Matrix.new([
      [8.0, 2.0, 2.0, 2.0],
      [3.0, -1.0, 7.0, 0.0],
      [7.0, 0.0, 5.0, 4.0],
      [6.0, -2.0, 0.0, 5.0],
    ])
    c = a * b
    (c * b.inverse).should eq(a)
  end
end
