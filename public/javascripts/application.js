var Login = {
    showOpenid: function() {
        if ($('database_auth_form')) $('database_auth_form').hide();
        if ($('openid_auth_form')) $('openid_auth_form').show();
        if ($('alternate_auth_openid')) $('alternate_auth_openid').hide();
        if ($('alternate_auth_database')) $('alternate_auth_database').show();
        if ($('openid_url')) $('openid_url').focus();
        if ($('openid_url')) $('openid_url').select();
        new CookieManager().setCookie('preferred_auth', 'openid');
    },

    showDatabase: function(container) {
        if ($('openid_auth_form')) $('openid_auth_form').hide();
        if ($('database_auth_form')) $('database_auth_form').show();
        if ($('alternate_auth_database')) $('alternate_auth_database').hide();
        if ($('alternate_auth_openid')) $('alternate_auth_openid').show();
        if ($('user_login')) $('user_login').focus();
        if ($('user_login')) $('user_login').select();
        new CookieManager().setCookie('preferred_auth', 'database');
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

/**
 * Provides a simple interface for creating, retrieving and clearing cookies.
 * Adapted from Jonathan Buchanan's code at http://insin.woaf.net/code/javascript/cookiemanager.html 
 */
CookieManager = Class.create();
CookieManager.prototype =
{
    BROWSER_IS_IE:
    (document.all
        && window.ActiveXObject
        && navigator.userAgent.toLowerCase().indexOf("msie") > -1
        && navigator.userAgent.toLowerCase().indexOf("opera") == -1),

    /**
     * I hate navigator string based browser detection too, but when Opera alone
     * chokes on cookies containing double quotes...
     */
    BROWSER_IS_OPERA:
    (navigator.userAgent.toLowerCase().indexOf("opera") != -1),

    initialize: function(options)
    {
        this.options = Object.extend({
            shelfLife: 365,
            userData: false
        }, options || {});

        this.cookieShelfLife = this.options.shelfLife;
        this.userDataForIE = this.options.userData;

        // Internet Explorer has a cookie handling bug - if the *combined size*
        // of all cookies stored for a given domain is greater than 4096 bytes,
        // document.cookie will return an empty string. Until this is fixed, we
        // can fall back on IE's proprietary userData behaviour if necessary.
        if (this.BROWSER_IS_IE && this.userDataForIE)
        {
            this.IE_CACHE_NAME = "storage";
            if ($(this.IE_CACHE_NAME) == null)
            {
                var div = document.createElement("DIV");
                div.id = this.IE_CACHE_NAME;
                document.body.appendChild(div);
            }
            this.store = $(this.IE_CACHE_NAME);
            this.store.style.behavior = "url('#default#userData')";
        }
    },

    /**
     * Returns the value of a cookie with the given name, or <code>null</code>
     * if no such cookie exists.
     */
    getCookie: function(aCookieName)
    {
        var result = null;
        if (this.BROWSER_IS_IE && this.userDataForIE)
        {
            this.store.load(this.IE_CACHE_NAME);
            result = this.store.getAttribute(aCookieName);
        }
        else
        {
            for (var i = 0; i < document.cookie.split('; ').length; i++)
            {
                var crumb = document.cookie.split('; ')[i].split('=');
                if (crumb[0] == aCookieName && crumb[1] != null)
                {
                    result = crumb[1];
                    break;
                }
            }
        }

        if (this.BROWSER_IS_OPERA && result != null)
        {
            result = result.replace(/%22/g, '"');
        }
        return result;
    },

    /**
     * Sets a cookie with the given name and value.
     */
    setCookie: function(aCookieName, aCookieValue)
    {
        if (this.BROWSER_IS_IE && this.userDataForIE)
        {
            this.store.setAttribute(aCookieName, aCookieValue);
            this.store.save(this.IE_CACHE_NAME);
        }
        else
        {
            if (this.BROWSER_IS_OPERA)
            {
                aCookieValue = aCookieValue.replace(/"/g, "%22");
            }
            var date = new Date();
            date.setTime(date.getTime() + (this.cookieShelfLife * 24*60*60*1000));
            var expires = '; expires=' + date.toGMTString();
            document.cookie = aCookieName + '=' + aCookieValue + expires + '; path=/';
        }
    },

    /**
     * Clears the cookie with the given name.
     */
    clearCookie: function(aCookieName)
    {
        if (this.BROWSER_IS_IE && this.userDataForIE)
        {
            this.store.load(this.IE_CACHE_NAME);
            this.store.removeAttribute(aCookieName);
            this.store.save(this.IE_CACHE_NAME);
        }
        else
        {
            document.cookie =
            aCookieName + '=;expires=Thu, 01-Jan-1970 00:00:01 GMT; path=/';
        }
    }
}
