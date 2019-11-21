# frozen_string_literal: true

module EresStats
  class StreamingVideoNoncoll < Query
    SQL = <<~SQL
      select distinct b.id
      from sierra_view.bib_record b
      inner join sierra_view.bib_record_item_record_link bl on bl.bib_record_id = b.id
      inner join sierra_view.varfield vi on vi.record_id = bl.item_record_id
        and vi.varfield_type_code = 'j' and vi.field_content ilike '%Streaming Video%'
      where b.bcode3 NOT IN ('d', 'n', 'c')
    SQL

    OUTFILE = 'streaming_video_noncoll.txt'

    def processors
      [
        DupeChecker.new,
        Warn856uBlank.new,
        Bad856x.new,
        WarnNoAALLocs.new,
        Warn773NotBlank.new,
        RequireAllLocations.new(['er', 'es']),
        WarnNoFilmfinder.new
      ]
    end
  end
end
