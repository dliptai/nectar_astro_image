
intel_items = [
  'ifort',
  'icc',
  'icpc',
  'gdb-ia'
]

control 'intel' do
  impact 1.0
  title 'Intel Parallel Studio installation'
  desc 'check for intel compilers'

  intel_items.each do |item|
    describe command(item) do
      it {should exist}
    end

    describe command(%Q{#{item} --version}) do
      its('exit_status') {should cmp 0}
    end
  end

end
