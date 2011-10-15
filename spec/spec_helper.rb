require 'fileutils'
require 'tmpdir'
require 'neo4j'

require 'neo4j/replay'
require 'fixture.rb'

Neo4j::Config[:storage_path] = File.join(Dir.tmpdir, "neo4j-rspec-db")
Neo4j::Config[:debug_java] = true

def rm_db_storage
  FileUtils.rm_rf Neo4j::Config[:storage_path]
  raise "Can't delete db" if File.exist?(Neo4j::Config[:storage_path])
end

def finish_tx
  return unless @tx
  begin
    @tx.success
    @tx.finish
  rescue Exception => e
    if e.respond_to?(:cause)
      puts "Java Exception in a transaction, cause: #{e.cause}"
      e.cause.print_stack_trace
    end
    raise
  end
  @tx = nil
end

def new_tx
  finish_tx if @tx
  @tx = Neo4j::Transaction.new
end

# set database storage location
Neo4j::Config[:storage_path] = File.join(Dir.tmpdir, 'neo4j-replay-rspec')

RSpec.configure do |c|
  $name_counter = 0

  c.before(:all) do
    rm_db_storage unless Neo4j.running?
  end

end

