jQuery(document).ready(function($) {
    // Read More functionality
    $('.read-more').on('click', function() {
        var testimonial = $(this).prev('.testimonial');
        
        if (testimonial.hasClass('expanded')) {
            testimonial.removeClass('expanded');
            $(this).text('READ MORE');
        } else {
            testimonial.addClass('expanded');
            $(this).text('READ LESS');
        }
    });
});
