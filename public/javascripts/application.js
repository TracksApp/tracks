var Login = {
    showOpenid: function() {
        $('#database_auth_form').hide();
        $('#openid_auth_form').show();
        $('#alternate_auth_openid').hide();
        $('#alternate_auth_database').show();
        $('#openid_url').focus();
        $('#openid_url').select();
        $.cookie('preferred_auth', 'openid');
    },

    showDatabase: function(container) {
        $('#openid_auth_form').hide();
        $('#database_auth_form').show();
        $('#alternate_auth_database').hide();
        $('#alternate_auth_openid').show();
        $('#user_login').focus();
        $('#user_login').select();
        $.cookie('preferred_auth', 'database');
    }
}

var TracksForm = {
    toggle: function(toggleDivId, formContainerId, formId, hideLinkText, hideLinkTitle, showLinkText, showLinkTitle) {
        $(formContainerId).toggle();
        toggleDiv = $(toggleDivId);
        toggleLink = toggleDiv.down('a');
        if (toggleDiv.hasClassName('hide_form')) {
            toggleLink.update(showLinkText).setAttribute('title', showLinkTitle);
        }
        else {
            toggleLink.update(hideLinkText).setAttribute('title', hideLinkTitle);
            Form.focusFirstElement(formId);
        }
        toggleDiv.toggleClassName('hide_form');
    }, 
    get_period: function() {
        if ($('recurring_todo_recurring_period_daily').checked) {
            return 'daily';
        } 
        else if ($('recurring_todo_recurring_period_weekly').checked) {
            return 'weekly';
        }
        else if ($('recurring_todo_recurring_period_monthly').checked) {
            return 'monthly';
        }
        else if ($('recurring_todo_recurring_period_yearly').checked) {
            return 'yearly';
        }
        else {
            return 'no period'
        }
    },
    get_edit_period: function() {
        if ($('recurring_edit_todo_recurring_period_daily').checked) {
            return 'daily';
        } 
        else if ($('recurring_edit_todo_recurring_period_weekly').checked) {
            return 'weekly';
        }
        else if ($('recurring_edit_todo_recurring_period_monthly').checked) {
            return 'monthly';
        }
        else if ($('recurring_edit_todo_recurring_period_yearly').checked) {
            return 'yearly';
        }
        else {
            return 'no period'
        }
    },
    hide_all_recurring: function () {
        $('recurring_daily').hide();
        $('recurring_weekly').hide();
        $('recurring_monthly').hide();
        $('recurring_yearly').hide();
    },
    hide_all_edit_recurring: function () {
        $('recurring_edit_daily').hide();
        $('recurring_edit_weekly').hide();
        $('recurring_edit_monthly').hide();
        $('recurring_edit_yearly').hide();
    },
    toggle_overlay: function () {
        el = document.getElementById("overlay");
        el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
    }
}

var TodoBehavior = {
    enableToggleNotes: function() {
        jQuery(".show_notes").unbind('click').bind('click', function () {
            jQuery(this).next().toggle("fast"); return false;
        });
    }
}

/****************************************
 * Unobtrusive jQuery written by Eric Allen
 ****************************************/

/* Set up authenticity token proplery */
$(document).ajaxSend(function(event, request, settings) {
  if ( settings.type == 'POST' ) {
    settings.data = (settings.data ? settings.data + "&" : "")
      + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN ) + "&"
      + "_source_view=" + encodeURIComponent( SOURCE_VIEW );
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  }
  request.setRequestHeader("Accept", "text/javascript");
});

function toggle_star_remote(ev){
  ev.preventDefault();
  $.post(this.href, {_method: 'put'}, null, 'script');
}

function toggle_checkbox_remote(ev){
  params = {_method: 'put'};
  if(typeof(TAG_NAME) !== 'undefined')
    params._tag_name = TAG_NAME;
  $.post(this.value, params, null, 'script');
}

function set_behavior_for_tag_edit_todo(){
  /*
    apply_behavior 'form.edit_todo_form', make_remote_form(
      :method => :put, 
      :before => "todoSpinner = this.down('button.positive'); todoSpinner.startWaiting()",
      :loaded => "todoSpinner.stopWaiting()",
      :condition => "!(this.down('button.positive').isWaiting())"),
      :prevent_default => true
      */
}

function setup_container_toggles(){
  // bind handlers
  // set to cookied state
}

/* Unobtrusive jQuery behavior */

$(document).ready(function() {
  /* fade flashes automatically */
  $(".alert").fadeIn(8000);

  /* set behavior for star icon */
  $(".item-container a.star_item").
    live('click', toggle_star_remote);

  /* set behavior for toggle checkboxes */
  $(".item-container input.item-checkbox").
    live('click', toggle_checkbox_remote);

  setup_container_toggles();
});
