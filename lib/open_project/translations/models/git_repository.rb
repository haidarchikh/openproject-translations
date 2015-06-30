require_relative '../helpers/run_command'

class GitRepository
  include RunCommand

  def initialize(uri, path)
    @uri = uri
    @path = path
  end

  def clone_or_pull
    if File.directory? File.join(@path, '.git')
      within_repo do
        run_command "git fetch"
      end
    #elsif File.directory? @path
      # maybe we should:
      # raise "Cannot checkout #{@uri} to #{@path}. Directory already exists but has no .git folder."
      # or ask if the directory should be overwritten
    else
      run_command "git clone #{@uri} #{@path}"
    end
  end

  def checkout(ref)
    within_repo do
      # todo this does not need to be a branch..
      @branch = ref
      run_command "git checkout --force '#{ref}' --"
    end
  end

  def within_repo
    Dir.chdir @path do
      yield
    end
  end

  def submodule_init_and_update
    within_repo do
      run_command 'git submodule update --init'
    end
  end

  def add(path)
    within_repo do
      run_command "git add #{path}"
    end
  end

  def commit(message)
    within_repo do
      run_command "git commit -m '#{message}'"
    end
  end

  def push(push_tags = nil)
    command = 'git push'
    command << ' --tags' if push_tags
    within_repo do
      run_command 'git push'
    end
  end

  def merge(their_branch, options = nil)
    command = "git merge origin/#{their_branch}"
    command = command + ' ' + options if options
    command = command + " -m \"Merge branch '#{their_branch}' into #{@branch}'\""
    within_repo do
      run_command command
    end
  end
end
