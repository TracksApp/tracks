class Article < ActiveRecord::Base
  def validate
    # t('li')
    errors.add_to_base([t(:'article.key1') + "#{t('article.key2')}"])
    I18n.t 'article.key3'
    I18n.t 'article.key3'
    I18n.t :'article.key4'
    I18n.translate :'article.key5'
    'bla bla t' + "blubba bla" + ' foobar'
    'bla bla t ' + "blubba bla" + ' foobar'
  end
end
