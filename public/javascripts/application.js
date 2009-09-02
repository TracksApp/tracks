var Login = {
    showOpenid: function() {
        if ($('database_auth_form')) $('database_auth_form').hide();
        if ($('openid_auth_form')) $('openid_auth_form').show();
        if ($('alternate_auth_openid')) $('alternate_auth_openid').hide();
        if ($('alternate_auth_database')) $('alternate_auth_database').show();
        if ($('openid_url')) $('openid_url').focus();
        if ($('openid_url')) $('openid_url').select();
        $.cookie('preferred_auth', 'openid');
    },

    showDatabase: function(container) {
        if ($('openid_auth_form')) $('openid_auth_form').hide();
        if ($('database_auth_form')) $('database_auth_form').show();
        if ($('alternate_auth_database')) $('alternate_auth_database').hide();
        if ($('alternate_auth_openid')) $('alternate_auth_openid').show();
        if ($('user_login')) $('user_login').focus();
        if ($('user_login')) $('user_login').select();
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
// uncomment the next four lines for easier debugging with FireBug
// Ajax.Responders.register({
//  onException: function(source, exception) {
//    console.error(exception);
//  }
// });

/* fade flashes automatically */
Event.observe(window, 'load', function() { 
    $A(document.getElementsByClassName('alert')).each(function(o) {
        o.opacity = 100.0
        Effect.Fade(o, {
            duration: 8.0
        })
    });
});

