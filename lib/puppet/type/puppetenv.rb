Puppet::Type.newtype(:puppetenv) do
  @doc = "Manage Puppet environment variables"

  ensurable do
    desc "Manage Environment variables used by Puppet when it runs."

    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc "The variable name."
    isnamevar
  end

  newparam(:value) do
    desc "The value of the environment variable."
  end

end
