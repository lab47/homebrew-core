class Idris2 < Formula
  desc "Pure functional programming language with dependent types"
  homepage "https://www.idris-lang.org/"
  url "https://github.com/idris-lang/Idris2/archive/v0.5.1.tar.gz"
  sha256 "da44154f6eba5e22ec5ac64c6ba2c28d2df0a57cf620c5b00c11adb51dbda399"
  license "BSD-3-Clause"
  head "https://github.com/idris-lang/Idris2.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 big_sur:      "bdfd0d5b4d48cc19c8e461aab87b3a1e5f905f045e4e7c7d72cbee9a63c72ddc"
    sha256 cellar: :any,                 catalina:     "83ecdfb8924bbe5adbf4c2cd77157445751f76aafe7881a64fa668f3e0bcf941"
    sha256 cellar: :any,                 mojave:       "be86b55b7c0b1b27f4b6e79ba7d8da3e5341192a7d0cc623e3f455d4373ff227"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "dab5f03fda85ba0cd3b3bc26c1bed3317f5412f22bb0e1919b7985105182889e"
  end

  depends_on "coreutils" => :build
  depends_on "gmp" => :build
  depends_on "chezscheme"
  uses_from_macos "zsh" => :build, since: :mojave

  def install
    ENV.deparallelize
    scheme = Formula["chezscheme"].bin/"chez"
    system "make", "bootstrap", "SCHEME=#{scheme}", "PREFIX=#{libexec}"
    system "make", "install", "PREFIX=#{libexec}"
    bin.install_symlink libexec/"bin/idris2"
    lib.install_symlink Dir["#{libexec}/lib/#{shared_library("*")}"]
    (bash_completion/"idris2").write Utils.safe_popen_read(bin/"idris2", "--bash-completion-script", "idris2")
  end

  test do
    (testpath/"hello.idr").write <<~EOS
      module Main
      main : IO ()
      main =
        let myBigNumber = (the Integer 18446744073709551615 + 1) in
        putStrLn $ "Hello, Homebrew! This is a big number: " ++ ( show $ myBigNumber )
    EOS

    system bin/"idris2", "hello.idr", "-o", "hello"
    assert_equal "Hello, Homebrew! This is a big number: 18446744073709551616",
                 shell_output("./build/exec/hello").chomp
  end
end
