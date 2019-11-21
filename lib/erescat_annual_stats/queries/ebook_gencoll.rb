# frozen_string_literal: true

module EresStats
  class EbookGencoll < Query
    SQL = <<~SQL
      select distinct b.id
      from sierra_view.bib_record b
      inner join sierra_view.bib_record_item_record_link bl on bl.bib_record_id = b.id
      inner join sierra_view.varfield vi on vi.record_id = bl.item_record_id
        and (
          (vi.varfield_type_code = 'j' and vi.field_content ilike '%E-book%')
          or
          (vi.varfield_type_code = 'c' and vi.field_content ~* '^[|]a *INTERNET *$')
        )
      where b.bcode3 NOT IN ('d', 'n', 'c')
        and NOT EXISTS(select *
                      from sierra_view.varfield vb
                      where vb.record_id = b.id
                      and vb.marc_tag = '040'
                      and vb.field_content ilike '%GPO%')
    SQL

    OUTFILE = 'ebook_gencoll.txt'

    def processors
      [
        DupeChecker.new,
        Warn856uBlank.new,
        Bad856x.new,
        WarnNoAALLocs.new,
        Warn773EstablishedColl.new,
        RequireAllLocations.new(['eb', 'er'])
      ]
    end
  end
end
