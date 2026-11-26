class Linn < Formula
  desc "Medium-term memory for coding agents: a local, evidence-backed lab notebook"
  homepage "https://github.com/kitten/linn"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    on_arm do
      url "https://github.com/kitten/linn/releases/download/v0.4.0/linn-0.4.0-macos-arm64.tar.gz"
      sha256 "f865c6972b38d3efac40bb80433ef23fef578acff53f9d3c42290f4bc640ccb0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kitten/linn/releases/download/v0.4.0/linn-0.4.0-linux-arm64.tar.gz"
      sha256 "b5857420add2428a9884abc4adc658e6692310165d0abcca131837059edf6689"
    end
    on_intel do
      url "https://github.com/kitten/linn/releases/download/v0.4.0/linn-0.4.0-linux-x86_64.tar.gz"
      sha256 "f18b910db2adeb9e9b71c777423b7d25a508a1ecc77322bc40e952d8812118e6"
    end
  end

  def install
    bin.install "linn"
    doc.install "README.md", "THIRD_PARTY_NOTICES", "NLP-LICENSE"
  end

  test do
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    ENV["XDG_DATA_HOME"] = testpath/"data"
    ENV["XDG_CACHE_HOME"] = testpath/"cache"
    ENV["XDG_STATE_HOME"] = testpath/"state"
    ENV["XDG_RUNTIME_DIR"] = testpath/"run"
    (testpath/"run").mkpath
    (testpath/"run").chmod 0700
    ENV["GIT_CONFIG_NOSYSTEM"] = "1"
    ENV["GIT_CONFIG_GLOBAL"] = File::NULL
    (testpath/"note.txt").write "The resolver preserves query parameters.\n"
    store = testpath/"memory.db"
    begin
      added = JSON.parse(shell_output("#{bin}/linn --store #{store} add note.txt --json"))
      result = JSON.parse(shell_output("#{bin}/linn --store #{store} search 'resolver query parameters' --json"))
      assert_includes result.fetch("cards").map { |card| card.fetch("record") }, added.fetch("record")
      shown = JSON.parse(shell_output("#{bin}/linn --store #{store} show #{added.fetch("record")} --all --json"))
      assert_equal (testpath/"note.txt").read, shown.fetch("text")
    ensure
      system bin/"linn", "--store", store, "daemon:stop"
    end
  end
end
