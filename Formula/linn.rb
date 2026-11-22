class Linn < Formula
  desc "Medium-term memory for coding agents: a local, evidence-backed lab notebook"
  homepage "https://github.com/kitten/linn"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    on_arm do
      url "https://github.com/kitten/linn/releases/download/v0.3.1/linn-0.3.1-macos-arm64.tar.gz"
      sha256 "fa24361acb79db215ba92c997e2215833d18ba99231f0525834a2e150016ade7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kitten/linn/releases/download/v0.3.1/linn-0.3.1-linux-arm64.tar.gz"
      sha256 "827e1ffaab9238e068bd73e22237999041f87fe87aa8f57b8690dc53ea348765"
    end
    on_intel do
      url "https://github.com/kitten/linn/releases/download/v0.3.1/linn-0.3.1-linux-x86_64.tar.gz"
      sha256 "1572fcddfff31770fb4f3d0b1f7eded8432a6fc0cc443b1c0a1899299497b78b"
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
