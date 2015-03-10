Puppet::Type.type(:puppetenv).provide(:envvar) do
  desc "Provider to set environment variables in Ruby when Puppet runs."

  def create
    ENV[@resource.value(:name)] = @resource.value(:value)
  end

  def destroy
    ENV.delete(@resource.value(:name))
  end

  def exists?
    if @resource.value(:ensure) == :present
      ENV[@resource.value(:name)] = @resource.value(:value)
      true
    else
      false
    end
  end

end
