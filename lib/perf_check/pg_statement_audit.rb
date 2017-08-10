module AuditPostgresStatements
  EXCLUDE_AUDIT_STATEMENTS = [/^EXPLAIN/i, /^DELETE/i, /^EXECUTE/i, /^INSERT/i, /^UPDATE/i]

  def execute(sql, name = nil)
    maybe_audit_call(sql, [])
    super
  end

  def execute_and_clear(sql, name, binds)
    maybe_audit_call(sql, binds)
    super
  end

  private

  def maybe_audit_call(sql, binds)
    if SQL_STATEMENT_FULL_AUDIT_ENABLED &&
      EXCLUDE_AUDIT_STATEMENTS.none? { |stmt| stmt.match(sql)}

      begin
        explain_query = build_explain(sql)
        ret = @connection.exec_query(explain_query, 'PERF_AUDIT', binds)
        analyze_result(JSON.parse(ret.first)[0])
      rescue
        ""
      end
    end
  end

  def build_explain(sql)
    "EXPLAIN (ANALYZE, VERBOSE, FORMAT JSON) #{sql}"
  end

  def self.analyze_result(explain_data)
    plan_problems = parse_plan(explain_data['Plan'])
    unless plan_problems.empty?
      ActiveSupport::Notifications.instrument "plan_performance_pitfall.perfcheck", this:
        :data do
        format_plan_problems(plan_problems)
      end
    end
  end

  def self.format_plan_problems(plan_problems)

  end

  def self.parse_plan(node)
    issues = parse_node(node)
    if node.key?('Plans')
      node['Plans'].each do |plan|
        issues << parse_plan(plan)
      end
    end
    issues
  end

  def self.parse_node(node)
    []
  end

end

#ConnectionAdapters::PostgreSQLAdapter.send(:prepend,PerfCheck::AuditPostgresStatements)
