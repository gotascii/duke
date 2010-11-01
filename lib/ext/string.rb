class String
  REPO_REGEX = /\/(.*).git$/
  def repo_dir
    self =~ REPO_REGEX ? $1 : self
  end

  def repo_url?
    !!(self =~ REPO_REGEX)
  end
end