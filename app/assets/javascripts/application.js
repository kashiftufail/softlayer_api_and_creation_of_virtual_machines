// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery-1.7.1
//= require jquery_ujs
//= require_tree .


function disable_user(id) {

    if (confirm('Are you sure you want to disable user and virtual machine power off?')) {

        var container = $("#users_list");
        $.ajax({
            url: '/users/disable_user?id=' + id,
            type: 'get',
            dataType: 'html',
            processData: false,
            success: function(data) {
                container.html(data);
            }
        });
    }
}

function enable_user(id) {

    if (confirm('Are you sure you want to enable user and virtual machine power on?')) {

        var container = $("#users_list");
        $.ajax({
            url: '/users/enable_user?id=' + id,
            type: 'get',
            dataType: 'html',
            processData: false,
            success: function(data) {
                container.html(data);
            }
        });
    }
}