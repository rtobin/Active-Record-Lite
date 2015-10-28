require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      through_tbl = through_options.table_name
      through_p_key = through_options.primary_key
      through_f_key = through_options.foreign_key

      source_options = through_options.model_class.assoc_options[source_name]
      source_tbl = source_options.table_name
      source_p_key = source_options.primary_key
      source_f_key = source_options.foreign_key

      id = self.send(through_f_key)
      stuff = DBConnection.execute(<<-SQL, id )
        SELECT
          #{source_tbl}.*
        FROM
          #{through_tbl}
        JOIN
          #{source_tbl}
        ON
          #{through_tbl}.#{source_f_key} = #{source_tbl}.#{source_p_key}
        WHERE
          #{through_tbl}.#{through_p_key} = ?
        ;
      SQL

      source_options.model_class.parse_all(stuff).first
    end
  end
end
