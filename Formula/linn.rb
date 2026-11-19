class Linn < Formula
  desc "Medium-term memory for coding agents: a local, evidence-backed lab notebook"
  homepage "https://github.com/kitten/linn"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    on_arm do
      url "https://github.com/kitten/linn/releases/download/v0.2.5/linn-0.2.5-macos-arm64.tar.gz"
      sha256 "bbe5ed5b2c62a51dfa7026c0102bc343f2d37f4f5d60fca35853ed0b645de326"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kitten/linn/releases/download/v0.2.5/linn-0.2.5-linux-arm64.tar.gz"
      sha256 "b5dfa81e8328bb9bd4d54b8236100c74856edfd05c9a52ead4651ad57d77f491"
    end
    on_intel do
      url "https://github.com/kitten/linn/releases/download/v0.2.5/linn-0.2.5-linux-x86_64.tar.gz"
      sha256 "d7b0c6d4943caa5745d92ce7d17198094f53ea09204ee9bd91f0aaf3e69d9956"
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
