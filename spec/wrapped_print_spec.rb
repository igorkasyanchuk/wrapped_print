class A
  def calc
    z = balance.wp
    100 + 200 + z
  end

  def balance
    500
  end
end

RSpec.describe WrappedPrint do
  it "has a version number" do
    expect(WrappedPrint::VERSION).not_to be nil
  end

  it "does something useful" do
    expect("Hello".wp).to eq("Hello")
    expect(wp { "World" }).to eq("World")
    expect("Hello".wp("key: ")).to eq("Hello")
    expect("Hello".wp("value: ", prefix: "\n", suffix: "\n\n")).to eq("Hello")

    a = "Demo"
    a.wp

    x = 1
    y = 2
    z1 = x.wp("X:") + y.wp("Y:")
    # same as
    z2 = x + y
    expect(z1).to eq(3)
    expect(z2).to eq(3)


    "Demo with color 1".wp(color: :red)
    "Demo with color 2".wp(color: :pur)
    "Demo with color 3".wp("COLORIZED: ", color: :pur, pattern: '*')
    "Demo with color 4".__wp__("COLORIZED: ", color: :blue, pattern: '*')

    a = A.new
    expect(a.calc).to eq(800)
  end

end
