module I18n::Backend::Pluralization
  # rules taken from : http://www.gnu.org/software/hello/manual/gettext/Plural-forms.html
  def pluralize(locale, entry, n)
    return entry unless entry.is_a?(Hash) && n
    if n == 0 && entry.has_key?(:zero)
      key = :zero
    else
      key = case locale
              when :pl # Polish
                n==1 ? :one : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? :few : :other
              when :cs, :sk # Czech, Slovak
                n==1 ? :one : (n>=2 && n<=4) ? :few : :other
              when :lt # Lithuanian
                n%10==1 && n%100!=11 ? :one : n%10>=2 && (n%100<10 || n%100>=20) ? :few : :other
              when :lv # Latvian
                n%10==1 && n%100!=11 ? :one : n != 0 ? :few : :other
              when :ru, :uk, :sr, :hr # Russian, Ukrainian, Serbian, Croatian
                n%10==1 && n%100!=11 ? :one : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? :few : :other
              when :sl # Slovenian
                n%100==1 ? :one : n%100==2 ? :few : n%100==3 || n%100==4 ? :many : :other
              when :ro # Romanian
                n==1 ? :one : (n==0 || (n%100 > 0 && n%100 < 20)) ? :few : :other
              when :gd # Gaeilge
                n==1 ? :one : n==2 ? :two : :other;
              # add another language if you like...
              else
                n==1 ? :one : :other # default :en
            end
    end
    raise InvalidPluralizationData.new(entry, n) unless entry.has_key?(key)
    entry[key]
  end
end

I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)