var LinkHelpers = {
  activateLinks: function() {
    this.activateInspectorLink();
    this.activateAddTorrentLink();
    this.activateSettingsLink();
    this.activateStatisticsLink();
    this.activateSpeedLimitModeLink();
    this.activateCompactViewLink();
    this.activateStartAndStopAllLink();
  },
  
  activateInspectorLink: function() {
    var context = this;
    
    $('#inspector').click(function() {
      if(context.infoIsOpen() && (window.location.hash.match(/\/torrents\/\d+/) ||
          window.location.hash.match(/\/torrent_details/))) {
        context.closeInfo(context);
      } else {
        context.redirect('#/torrent_details');
      }      
      return false;
    });
  },
  
  activateAddTorrentLink: function() {
    var context = this;
    $('#add_a_torrent').click(function() {
      if(context.infoIsOpen() && window.location.hash.match('/torrents/new')) {
        context.closeInfo(context);
      } else {
        window.location.hash = '/torrents/new';
      }
      return false;
    });
  },

  activateSpeedLimitModeLink: function() {
    $('#speed_limit_mode').click(function() {
      var form = $('#speed_limit_mode_form');
      form.trigger('submit');
      if($(this).hasClass('active')) {
        $(this).removeClass('active');
        $(this).text('Enable Speed Limit Mode');
        form.find('input:first').attr('value', 'true');
      } else {
        $(this).addClass('active');
        $(this).text('Disable Speed Limit Mode');
        form.find('input:first').attr('value', 'false');
      }
      return false;
    });
  },

  activateCompactViewLink: function() {
    var context = this, redirect_path = '';
    
    if(transmission.store.get('view_mode') == 'compact') {
      $('#compact_view').addClass('active');
      $('#compact_view').text('Disable Compact View');      
    }
    
    $('#compact_view').click(function() {
      if($(this).hasClass('active')) {
        $(this).removeClass('active');
        $(this).text('Enable Compact View');
        redirect_path = '#/torrents?view=normal';
      } else {
        $(this).addClass('active');
        $(this).text('Disable Compact View');
        redirect_path = '#/torrents?view=compact';
      }
      context.redirect(redirect_path);
      return false;
    });
  },
  
  activateStartAndStopAllLink: function() {
    $('#start_all').click(function() {
      var selected_ids = $.map($('.torrent'), function(torrent) {return $(torrent).attr('id')}).join(',');
      $('#context_menu .activate form .ids').val(selected_ids);
      $('#context_menu .activate form').submit();      
    });
    
    $('#stop_all').click(function() {
      var selected_ids = $.map($('.torrent'), function(torrent) {return $(torrent).attr('id')}).join(',');
      $('#context_menu .pause form .ids').val(selected_ids);
      $('#context_menu .pause form').submit();
    });
  },
  
  activateSettingsLink: function() {
    var context = this;
    $('#settings').click(function() {
      if(context.infoIsOpen() && window.location.hash.match('/settings')) {
        context.closeInfo(context);
      } else {
        context.redirect('#/settings');
      }
      return false;
    });
  },

  activateStatisticsLink: function() {
    var context = this;
    $('#statistics').click(function() {
      if(context.infoIsOpen() && window.location.hash.match('/statistics')) {
        context.closeInfo(context);
      } else {
        context.redirect('#/statistics');
      }
      return false;
    });
  }
}