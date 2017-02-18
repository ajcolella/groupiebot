class PinterestBot
  attr_accessor :agent, :csrftoken

  def sign_in(email, password)
    @agent = Mechanize.new

    url = 'https://www.pinterest.com/resource/UserSessionResource/create/'
    data = {
      options: { username_or_email: email, password: password },
      context: {}
    }
    params = {
      source_url: '/login/',
      module_path: 'App()>LoginPage()>Login()>Button(class_name=primary, text=Log In, type=submit, size=large)',
      data: data.to_json
    }
    headers = default_headers
    headers['Cookie'] = 'csrftoken=1234;'
    headers['X-CSRFToken'] = '1234'

    res = @agent.post(url, params, headers)

    @agent.cookies.each do |c|
      if c.name == 'csrftoken'
        @csrftoken = c.value.to_s
      end
    end

    { code: res.code, body: JSON.parse(res.body) }.as_json
  rescue StandardError => e
    raise "PinterestScraper SignIn Error: #{e.message}"
  end

  def create_pin(board_id, link, image_url, description)
    url = 'https://www.pinterest.com/resource/PinResource/create/'
    data = {
      options: { board_id: board_id , description: description, link: link, image_url: image_url, method: "bookmarklet", is_video: nil },
      context: {}
    }
    params = {
      source_url: "/pin/create/bookmarklet/?url=#{link.to_param}",
      pinFave: 1,
      description: description.to_param,
      data: data.to_json,
      module_path: "module_path=App()>PinBookmarklet()>PinCreate()>PinForm(description=, default_board_id=null, show_cancel_button=true, cancel_text=Close, link=, show_uploader=false, image_url=, is_video=null, heading=Pick a board, pin_it_script_button=true)"
    }
    headers = default_headers
    headers['X-CSRFToken'] = @csrftoken

    res = @agent.post(url, params, headers)
    body = JSON.parse(res.body)
    pin_id = body['resource_response']['data']['id']

    { code: res.code, body: body, pin_id: pin_id }.as_json
  rescue StandardError => e
    raise "PinterestScraper CreatePin Error: #{e.message}"
  end

  def get_boards
    url = 'https://www.pinterest.com/resource/BoardPickerBoardsResource/get/'
    data = {
      options: { filter: 'all', field_set_key: 'board_picker'},
      context: {}
    }
    params = {
      data: data.to_json,
      module_path: 'module_path=App>Closeup>PinActionBar>PinLikeButton(class_name=like pinActionBarButton isBrioFlat, liked=false, size=medium, has_icon=true, pin_id=AW8s1yWf2x7pJHSqP9iGVmBGjgbRuMh_xZN2RwlTaRJE5OCwhm5Mr3Q, show_text=true, text=Like, state_badgeValue="", state_accessibilityText=Like, state_disabled=undefined)'
    }
    headers = default_headers
    headers['X-CSRFToken'] = @csrftoken

    res = @agent.post(url, params, headers)
    body = JSON.parse(res.body)
    byebug
    boards = body['resource_response']['data']['all_boards']

    { code: res.code, body: body, boards: boards }.as_json
  rescue StandardError => e
    raise "PinterestScraper GetBoards Error: #{e.message}"
  end

  def like_pins(pin_ids)
    pin_ids.each { |id| like_pin(id) }
  end

  def like_pin(pin_id)
    # AW8s1yWf2x7pJHSqP9iGVmBGjgbRuMh_xZN2RwlTaRJE5OCwhm5Mr3Q
    url = 'https://www.pinterest.com/resource/PinLikeResource/create/'
    data = {
      options: { pin_id: pin_id},
      context: {}
    }
    params = {
      data: data.to_json
    }
    headers = default_headers
    headers['X-CSRFToken'] = @csrftoken

    res = @agent.post(url, params, headers)
    body = JSON.parse(res.body)

    { code: res.code, body: body, pin_id: pin_id }.as_json
  rescue StandardError => e
    raise "PinterestScraper GetBoards Error: #{e.message}"
  end

  def get_pin_ids(term)
    page = Nokogiri::HTML(RestClient.get("https://www.pinterest.com/search/pins/?q=#{term}"))
    pin_list = page.css('body').css('.App').css('.appContent').css('.mainContainer')
      .css('.SearchPage').css('.SearchPageContent').css('.Grid').css('.GridItems').css('.item')
    pin_ids = pin_list.map do |c| 
      c.css('.Module').css('.pinWrapper').css('.pinImageActionButtonWrapper')
        .css('.pinHolder').css('a')[0].attributes['href'].value.split('/')[2]
    end
  end

  private

  def default_headers
    {
      'Host' => 'www.pinterest.com',
      'Accept' => 'application/json, text/javascript, */*; q=0.01',
      'Accept-Language' => 'en-US,en;q=0.5',
      'DNT' => '1',
      'Referer' => 'https://www.pinterest.com/',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.104 Safari/537.36',
      'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-Pinterest-AppState' => 'active',
      'X-NEW-APP' => '1',
      'X-APP-VERSION' => 'b1bed37',
      'X-Requested-With' => 'XMLHttpRequest',
    }
  end
end