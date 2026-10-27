
Redmine::Plugin.register :redmine_impersonate do
  name "Redmine Impersonate"
  author "Ralph Gutkowski"
  description "Login as any user with click of a button."
  version '2.1.0'
  url 'https://github.com/viltgroup/redmine_impersonate'
  author_url 'https://github.com/rgtk'

  # Verified on Redmine 7.0.2. Earlier releases are untested -- widen this if
  # you verify one.
  requires_redmine version_or_higher: '7.0.0'
end

RedmineImpersonate.install
