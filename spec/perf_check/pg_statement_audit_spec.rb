
require 'spec_helper'
require 'perf_check/pg_statement_audit'

SIMPLE_PLAN = {'Plan' => {}}

module Rails
  def self.root
    "tmp/spec"
  end
end

module ActiveSupport
  module Notifications
    def self.subscribe(*args)
    end
  end
end

RSpec.describe AuditPostgresStatements do
  let(:audit_statements){ AuditPostgresStatements }

  describe "#analyze_result" do
    it "should parse a simple query plan" do
      expect(audit_statements.analyze_result(SIMPLE_PLAN)).to eq(nil)
    end

  end
end
