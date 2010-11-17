Given /a torrent with the name "([^\"]+)"( and a download rate of "([^\"]+)" B\/s)?$/ do |name, has_download_rate, download_rate|
  file_path = File.dirname(__FILE__) + '/../support/plural.json'
  File.open(file_path, 'w') do |f|
    f << '{"arguments": {"torrents":  [{"id":  1, "name": "' + name + '", "status": 4, "totalSize": 100, "sizeWhenDone": 100,"leftUntilDone": 50, "eta": 0, "uploadedEver": 0, "uploadRatio": 0, "rateDownload": ' + (has_download_rate ? download_rate : '0') + ',"rateUpload": 0, "metadataPercentComplete": 1, "addedDate": 27762987, "fileStats": []}]}}'
  end
end

Given /a torrent with an error "([^\"]+)"/ do |error|
  file_path = File.dirname(__FILE__) + '/../support/plural.json'
  File.open(file_path, 'w') do |f|
    f << '{"arguments": {"torrents":  [{"id":  1, "name": "my torrent", "status": 4, "totalSize": 100, "sizeWhenDone": 100,"leftUntilDone": 50, "eta": 0, "uploadedEver": 0, "uploadRatio": 0, "rateDownload": 0,"rateUpload": 0, "metadataPercentComplete": 1, "addedDate": 27762987, "fileStats": [], "error": 2, "errorString": "' + error + '"}]}}'
  end
end

Given /the torrent "([^\"]+)" has more info like the download directory which is "([^\"]+)"/ do |name, download_directory|  
  file_path = File.dirname(__FILE__) + '/../support/singular.json'
  File.open(file_path, 'w') {|f| f << '{"arguments": {"torrents": [{"id":  1, "name": "' + name + '", "status": 4, "totalSize": 100, "sizeWhenDone": 100,"leftUntilDone": 50, "eta": 0, "uploadedEver": 0, "uploadRatio": 0, "rateDownload": 0,"rateUpload": 0, "metadataPercentComplete": 1, "addedDate": 27762987, "downloadDir": "' + download_directory + '", "creator": "chaot", "hashString": "83ui72GYAYDg27ghg22e22e4235215", "comment": "", "isPrivate": true, "downloadedEver": 50, "haveString": "", "errorString": "", "peersGettingFromUs": 0, "peersSendingToUs": 0, "files": [], "fileStats": [], "pieceCount": 20, "pieceSize": 5, "trackerStats": [{"lastAnnounceTime": "12345678", "host": "my.tracker.com", "nextAnnounceTime": "12345678", "lastScrapeTime": "12345678", "seederCount": 0, "leecherCount": 0, "downloadCount": 1}]}]}}' }
end

Given /three torrents with the names "([^\"]+)" and the (download rates|stati|date added|left until done|ids|trackers) "([^\"]+)"/ do |names_string, attribute, attribute_string|
  names = names_string.split(',')
  attributes = attribute_string.split(',')
  torrents = []

  case(attribute)
  when 'stati'
    names.each_with_index do |name , i|
      torrents.push({"id" =>  i, "name" => name.strip, "status" => attributes[i].to_i, "totalSize" => 100, "sizeWhenDone" => 100, "leftUntilDone" => 50, "eta" => 0, "uploadedEver" => 0, "uploadRatio" => 0, "rateDownload" => 0,"rateUpload" => 0, "metadataPercentComplete" => 1, "addedDate" => 27762987})
    end
  when 'download rates'
    names.each_with_index do |name , i|
      torrents.push({"id" =>  i, "name" => name.strip, "status" => 4, "totalSize" => 100, "sizeWhenDone" => 100, "leftUntilDone" => 50, "eta" => 0, "uploadedEver" => 0, "uploadRatio" => 0, "rateDownload" => attributes[i].to_i, "rateUpload" => 0, "metadataPercentComplete" => 1, "addedDate" => 27762987})
    end
  when 'date added'
    names.each_with_index do |name , i|
      torrents.push({"id" =>  i, "name" => name.strip, "status" => 4, "totalSize" => 100, "sizeWhenDone" => 100, "leftUntilDone" => 50, "eta" => 0, "uploadedEver" => 0, "uploadRatio" => 0, "rateDownload" => 0, "rateUpload" => 0, "metadataPercentComplete" => 1, "addedDate" => attributes[i].to_i})
    end
  when 'left until done'
    names.each_with_index do |name , i|
      torrents.push({"id" =>  i, "name" => name.strip, "status" => 4, "totalSize" => 100, "sizeWhenDone" => 100, "leftUntilDone" => attributes[i].to_i, "eta" => 0, "uploadedEver" => 0, "uploadRatio" => 0, "rateDownload" => 0, "rateUpload" => 0, "metadataPercentComplete" => 1, "addedDate" => 27762987})
    end
  when 'ids'
    names.each_with_index do |name , i|
      torrents.push({"id" =>  attributes[i].to_i, "name" => name.strip, "status" => 4, "totalSize" => 100, "sizeWhenDone" => 100, "leftUntilDone" => 50, "eta" => 0, "uploadedEver" => 0, "uploadRatio" => 0, "rateDownload" => 0, "rateUpload" => 0, "metadataPercentComplete" => 1, "addedDate" => 27762987, "fileStats" => [], "files" => []})
    end
  when 'trackers'
    names.each_with_index do |name , i|
      torrents.push({"id" => i, "name" => name.strip, "status" => 4, "totalSize" => 100, "sizeWhenDone" => 100, "leftUntilDone" => 50, "eta" => 0, "uploadedEver" => 0, "uploadRatio" => 0, "rateDownload" => 0, "rateUpload" => 0, "metadataPercentComplete" => 1, "addedDate" => 27762987, "trackerStats" => ["host" => attributes[i].strip]})
    end    
  end
  
  file_path = File.dirname(__FILE__) + '/../support/plural.json'
  File.open(file_path, 'w') do |f|
    f << {"arguments" => {"torrents" => torrents}}.to_json
  end
end

When /^I click on the torrent$/ do
  $browser.li(:id, '1').click
end

When /^I double click on the torrent$/ do
  $browser.li(:id, '1').double_click
end

Then /the torrent should be highlighted/ do
  $browser.li(:id, '1').attribute_value(:class).should include('active')
end

When /I double click on the torrent "([^\"]+)"/ do |id|
  $browser.li(:id, id).double_click
end

When /I click on the torrent "([^\"]+)"/ do |id|
  $browser.li(:id, id).click
end