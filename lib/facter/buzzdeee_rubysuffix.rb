# 

Facter.add(:rubysuffix) do
  confine :kernel => [ 'OpenBSD' ]
  setcode do
    version = Facter.value(:rubyversion)
    rubysuffix = version.gsub(/^(\d+)\.(\d+)\..*/, '\1\2')
  end
end

