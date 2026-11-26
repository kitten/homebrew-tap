class GitPorter < Formula
  desc "Guarded Git handoff between your laptop and an agent box"
  homepage "https://github.com/kitten/git-porter"
  license "MIT"

  uses_from_macos "git"
  uses_from_macos "openssh"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    on_arm do
      url "https://github.com/kitten/git-porter/releases/download/v0.1.4/git-porter-0.1.4-macos-arm64.tar.gz"
      sha256 "55833cff317ce41cbf6d67d8f4b1d4d25f02553016a874cc57daf66f54296667"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kitten/git-porter/releases/download/v0.1.4/git-porter-0.1.4-linux-arm64.tar.gz"
      sha256 "b7fdf8e28c2ffb26444d0c8214eb00eabb09a104ee402b52c2913590941175d7"
    end
    on_intel do
      url "https://github.com/kitten/git-porter/releases/download/v0.1.4/git-porter-0.1.4-linux-x86_64.tar.gz"
      sha256 "e3ac82ae29b2703a1c3da752217304f559d07fdad1925ff24917622858df367f"
    end
  end

  def install
    bin.install "git-porter", "git-send", "git-receive"
    doc.install "README.md"
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
    system "git", "init", "--initial-branch=main"
    assert_match version.to_s, shell_output("#{bin}/git-porter --version")
    assert_match "No such file or directory", shell_output("#{bin}/git-porter key:public 2>&1", 1)
    %w[git-send git-receive].each do |command|
      assert_match "--branch requires a branch name", shell_output("#{bin}/#{command} --branch 2>&1", 1)
    end
  end
end
