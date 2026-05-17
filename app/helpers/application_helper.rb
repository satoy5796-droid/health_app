# app/helpers/application_helper.rb
module ApplicationHelper
  # どのURL（パス）からでも使い回せる完全自作のページネーションボタン生成関数
  def pure_rails_pagination(total_count, current_page, base_path, per_page = 10)
    total_pages = (total_count.to_f / per_page).ceil
    return '' if total_pages <= 1

    # 検索キーワードがあればページ遷移時も引き継ぐ
    query_params = {}
    query_params[:q] = params[:q] if params[:q].present?

    html = %(<nav class="flex items-center justify-center space-x-1" role="navigation" aria-label="Pager">)

    # 1. 「前へ」ボタンの生成
    if current_page > 1
      link_url = url_for(query_params.merge(page: current_page - 1))
      link_text = %(<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>前へ)
      html += link_to(link_text.html_safe, link_url, class: "inline-flex items-center justify-center px-3 h-9 text-sm font-semibold text-gray-600 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 hover:text-blue-600 hover:border-blue-300 transition-colors")
    end

    # 2. ページ番号ボタンの生成
    (1..total_pages).each do |page|
      if page == current_page
        html += %(<span class="inline-flex items-center justify-center w-9 h-9 text-sm font-bold text-white bg-blue-600 rounded-lg shadow-sm select-none" aria-current="page">#{page}</span>)
      else
        html += link_to(page.to_s, url_for(query_params.merge(page: page)), class: "inline-flex items-center justify-center w-9 h-9 text-sm font-medium text-gray-600 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 hover:text-blue-600 hover:border-blue-300 transition-colors")
      end
    end

    # 3. 「次へ」ボタンの生成（ブロック構文のエラーを完全に修正しました）
    if current_page < total_pages
      link_url = url_for(query_params.merge(page: current_page + 1))
      link_text = %(次へ<svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>)
      html += link_to(link_text.html_safe, link_url, class: "inline-flex items-center justify-center px-3 h-9 text-sm font-semibold text-gray-600 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 hover:text-blue-600 hover:border-blue-300 transition-colors")
    end

    html += %(</nav>)
    html.html_safe
  end

  def condition_badge(condition_value)
    case condition_value.to_i
    when 5
      %(<span class="text-xs px-2 py-0.5 rounded bg-teal-50 text-teal-700 font-medium">😊 5</span>)
    when 4
      %(<span class="text-xs px-2 py-0.5 rounded bg-emerald-50 text-emerald-700 font-medium">🙂 4</span>)
    when 3
      %(<span class="text-xs px-2 py-0.5 rounded bg-amber-50 text-amber-700 font-medium">😐 3</span>)
    when 2
      %(<span class="text-xs px-2 py-0.5 rounded bg-orange-50 text-orange-700 font-medium">🙁 2</span>)
    when 1
      %(<span class="text-xs px-2 py-0.5 rounded bg-rose-50 text-rose-700 font-medium">🤮 1</span>)
    else
      %(<span class="text-xs px-2 py-0.5 rounded bg-gray-50 text-gray-500 font-medium">-</span>)
    end.html_safe
  end
end
