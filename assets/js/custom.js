(function ($) {
  $(document).ready(function () {
    /*===== Navbar ======*/
    $('.header-section .navbar-toggler').click(function () {
      $('.header-section').toggleClass('menu-open');
      $('body').toggleClass('scroll-hidden');
    });

    /*===== Alumni Success Slider ======*/
    const swiperAlumni = document.querySelector('.swiper-alumni-success');
    if (swiperAlumni) {
      const totalAlumniSlides = swiperAlumni.querySelectorAll('.swiper-slide').length;

      new Swiper('.swiper-alumni-success', {
        loop: true,
        allowTouchMove: true,
        grabCursor: true,
        breakpoints: {
          0: { slidesPerView: 1.1, spaceBetween: 12 },
          768: { slidesPerView: 2, spaceBetween: 24 },
          1200: { slidesPerView: 3, spaceBetween: 24 }
        },
        navigation: {
          nextEl: ".swiper-alumni-next",
          prevEl: ".swiper-alumni-prev",
        },
        on: {
          init: function () {
            if (totalAlumniSlides <= 3) {
              document.querySelector('.swiper-alumni-next').style.display = 'none';
              document.querySelector('.swiper-alumni-prev').style.display = 'none';
            }
          }
        }
      });
    }

    /*===== Alumni Success Slider ======*/
    const swiperOurCandidates = document.querySelector('.swiper-our-candidates');
    if (swiperOurCandidates) {
      const totalOurCandidatesSlides = swiperOurCandidates.querySelectorAll('.swiper-slide').length;

      new Swiper('.swiper-our-candidates', {
        loop: true,
        allowTouchMove: true,
        grabCursor: true,
        breakpoints: {
          0: { slidesPerView: 1.1, spaceBetween: 12 },
          768: { slidesPerView: 2, spaceBetween: 24 },
          1200: { slidesPerView: 3, spaceBetween: 24 }
        },
        navigation: {
          nextEl: ".swiper-our-candidates-next",
          prevEl: ".swiper-our-candidates-prev",
        },
        on: {
          init: function () {
            if (totalOurCandidatesSlides <= 3) {
              document.querySelector('.swiper-our-candidates-next').style.display = 'none';
              document.querySelector('.swiper-our-candidates-prev').style.display = 'none';
            }
          }
        }
      });
    }

    /*===== Company Logo Marquee Sliders ======*/
    const companyLogoTop = document.querySelector('.swiper-company-logo-top');
    if (companyLogoTop) {
      new Swiper('.swiper-company-logo-top', {
        loop: true,
        allowTouchMove: false,
        speed: 6000,
        slidesPerView: 'auto',
        spaceBetween: 20,
        disableOnInteraction: false,
        autoplay: {
          delay: 0,
        }
      });
    }

    const companyLogoBottom = document.querySelector('.swiper-company-logo-bottom');
    if (companyLogoBottom) {
      new Swiper('.swiper-company-logo-bottom', {
        loop: true,
        allowTouchMove: false,
        speed: 6000,
        slidesPerView: 'auto',
        spaceBetween: 20,
        disableOnInteraction: false,
        autoplay: {
          delay: 0,
          reverseDirection: true
        }
      });
    }

    /*===== Recruiter Banner Match Cards Slider (≤1199px) ======*/
    const bannerMatchEl = document.querySelector('.swiper-banner-match');
    if (bannerMatchEl) {
      let bannerMatchSwiper = null;
      const bannerMatchMq = window.matchMedia('(max-width: 1199.98px)');

      const syncBannerMatchSwiper = () => {
        if (bannerMatchMq.matches) {
          if (bannerMatchSwiper) return;
          bannerMatchSwiper = new Swiper(bannerMatchEl, {
            slidesPerView: 1.12,
            spaceBetween: 16,
            centeredSlides: true,
            loop: false,
            initialSlide: 1,
            watchOverflow: true,
            pagination: {
              el: bannerMatchEl.querySelector('.banner-match-pagination'),
              clickable: true,
            },
            breakpoints: {
              768: {
                slidesPerView: 1.35,
                spaceBetween: 20,
              },
              992: {
                slidesPerView: 1.5,
                spaceBetween: 24,
              },
            },
          });
        } else if (bannerMatchSwiper) {
          bannerMatchSwiper.destroy(true, true);
          bannerMatchSwiper = null;
        }
      };

      syncBannerMatchSwiper();
      if (typeof bannerMatchMq.addEventListener === 'function') {
        bannerMatchMq.addEventListener('change', syncBannerMatchSwiper);
      } else if (typeof bannerMatchMq.addListener === 'function') {
        bannerMatchMq.addListener(syncBannerMatchSwiper);
      }
    }

    /*===== Recruiter Tech Marquee Slider ======*/
    const recruiterTechSlider = document.querySelector('.swiper-recruiter-tech');
    if (recruiterTechSlider) {
      new Swiper('.swiper-recruiter-tech', {
        loop: true,
        allowTouchMove: false,
        speed: 6000,
        slidesPerView: 'auto',
        spaceBetween: 0,
        disableOnInteraction: false,
        autoplay: {
          delay: 0,
        }
      });
    }

    /*===== Technologies slider ======*/
    const techCareersTop = document.querySelector('.swiper-tech-careers-top');
    if (techCareersTop) {
      new Swiper('.swiper-tech-careers-top', {
        loop: true,
        allowTouchMove: false,
        speed: 6000,
        slidesPerView: 'auto',
        spaceBetween: 20,
        autoplay: {
          delay: 0,
        },
      });
    }

    const techCareersBottom = document.querySelector('.swiper-tech-careers-bottom');
    if (techCareersBottom) {
      new Swiper('.swiper-tech-careers-bottom', {
        loop: true,
        allowTouchMove: false,
        speed: 6000,
        slidesPerView: 'auto',
        spaceBetween: 20,
        autoplay: {
          delay: 0,
          reverseDirection: true,
        },
      });
    }

    /*===== Quick Answer Swiper ======*/
    const quickAnswerSwiperEls = document.querySelectorAll(
      '.quick-answer-content .quick-answer-swiper'
    );
    if (quickAnswerSwiperEls.length) {
      quickAnswerSwiperEls.forEach((el) => {
        const sliderWrap = el.closest('.quick-answer-slider');
        const prevEl = sliderWrap?.querySelector('.swiper-quick-answer-prev');
        const nextEl = sliderWrap?.querySelector('.swiper-quick-answer-next');

        new Swiper(el, {
          loop: true,
          allowTouchMove: true,
          grabCursor: true,
          watchOverflow: true,
          slidesPerView: 1.1,
          spaceBetween: 12,
          breakpoints: {
            768: {
              slidesPerView: 2,
              spaceBetween: 24,
            },
            1200: {
              slidesPerView: 3,
              spaceBetween: 24,
            },
          },
          navigation:
            prevEl && nextEl
              ? {
                  prevEl,
                  nextEl,
                }
              : undefined,
        });
      });
    }

    /*===== You After ElevateMe (non-tech placement) ======*/
    const swiperYouAfterElevateme = document.querySelector('.swiper-you-after-elevateme');
    if (swiperYouAfterElevateme) {
      const totalYouAfterSlides = swiperYouAfterElevateme.querySelectorAll('.swiper-slide').length;
      const youAfterPrev = document.querySelector('.swiper-you-after-elevateme-prev');
      const youAfterNext = document.querySelector('.swiper-you-after-elevateme-next');

      new Swiper(swiperYouAfterElevateme, {
        loop: totalYouAfterSlides > 1,
        allowTouchMove: true,
        grabCursor: true,
        slidesPerView: 1,
        spaceBetween: 16,
        autoplay:
          totalYouAfterSlides > 1
            ? {
                delay: 5000,
                disableOnInteraction: false,
                pauseOnMouseEnter: true,
              }
            : false,
        breakpoints: {
          0: {
            slidesPerView: 1.1,
            spaceBetween: 12,
          },
          768: {
            slidesPerView: 1,
            spaceBetween: 24,
          },
        },
        navigation: {
          nextEl: '.swiper-you-after-elevateme-next',
          prevEl: '.swiper-you-after-elevateme-prev',
        },
        on: {
          init: function () {
            if (totalYouAfterSlides <= 1) {
              if (youAfterPrev) youAfterPrev.style.display = 'none';
              if (youAfterNext) youAfterNext.style.display = 'none';
            }
          },
        },
      });
    }

    /*===== Meet the People Slider ======*/
    const swiperMeetPeople = document.querySelector('.swiper-meet-people');
    if (swiperMeetPeople) {
      const totalMeetPeopleSlides = swiperMeetPeople.querySelectorAll('.swiper-slide').length;
      const meetPeoplePrev = document.querySelector('.swiper-meet-people-prev');
      const meetPeopleNext = document.querySelector('.swiper-meet-people-next');

      new Swiper('.swiper-meet-people', {
        loop: false,
        allowTouchMove: true,
        grabCursor: true,
        breakpoints: {
          0: { slidesPerView: 1.1, spaceBetween: 20 },
          768: { slidesPerView: 2, spaceBetween: 30 },
          992: { slidesPerView: 3, spaceBetween: 30 }
        },
        navigation: {
          nextEl: '.swiper-meet-people-next',
          prevEl: '.swiper-meet-people-prev',
        },
        on: {
          init: function () {
            if (totalMeetPeopleSlides <= 3) {
              if (meetPeoplePrev) meetPeoplePrev.style.display = 'none';
              if (meetPeopleNext) meetPeopleNext.style.display = 'none';
            }
          }
        }
      });
    }

    /*===== Smooth Scroll (Remove #id from URL) =====*/
    $('a.section-scroll[href^="#"]').on('click', function (e) {
      e.preventDefault(); // stop URL from updating

      const targetId = $(this).attr('href');
      const el = $(targetId);

      if (el.length) {
        $('html, body').animate(
          { scrollTop: el.offset().top - 200 }, // offset for header
          500
        );
      }
    });

    // Video play/pause button
    const coachVideo = document.getElementById("careerCoachVideo");
    const coachVideoBtn = document.getElementById("playPauseBtn");

    if (coachVideo && coachVideoBtn) {
      coachVideoBtn.addEventListener("click", () => {
        if (coachVideo.paused) {
          coachVideo.play();
          coachVideoBtn.classList.add("pause");
        } else {
          coachVideo.pause();
          coachVideoBtn.classList.remove("pause");
        }
      });

      // When video ends, reset button state
      coachVideo.addEventListener("ended", () => {
        coachVideoBtn.classList.remove("pause");
      });
    }

    // Fancybox
    Fancybox.bind("[data-fancybox]", {
      // Your custom options
    });

    // Let Our Numbers Speak - counter
    const metricValues = document.querySelectorAll('.success-student-info-section .metric-value');
    if (metricValues.length) {
      const getMetricParts = (valueText) => {
        const match = valueText.trim().match(/^([^0-9]*)(\d+(?:\.\d+)?)(.*)$/);
        if (!match) return null;
        return {
          prefix: match[1] || '',
          value: parseFloat(match[2]),
          suffix: match[3] || '',
          decimals: (match[2].split('.')[1] || '').length
        };
      };

      const animateMetric = (el) => {
        const metric = getMetricParts(el.textContent);
        if (!metric) return;

        const duration = 1400;
        const startTime = performance.now();

        const update = (now) => {
          const progress = Math.min((now - startTime) / duration, 1);
          const eased = 1 - Math.pow(1 - progress, 3);
          const current = metric.value * eased;
          const display =
            metric.decimals > 0 ? current.toFixed(metric.decimals) : Math.round(current).toString();

          el.textContent = `${metric.prefix}${display}${metric.suffix}`;

          if (progress < 1) {
            requestAnimationFrame(update);
          } else {
            el.textContent = `${metric.prefix}${metric.value % 1 === 0 ? metric.value.toFixed(0) : metric.value.toFixed(metric.decimals)}${metric.suffix}`;
          }
        };

        requestAnimationFrame(update);
      };

      if ('IntersectionObserver' in window) {
        const metricsObserver = new IntersectionObserver((entries, observer) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              animateMetric(entry.target);
              observer.unobserve(entry.target);
            }
          });
        }, { threshold: 0.5 });

        metricValues.forEach((el) => metricsObserver.observe(el));
      } else {
        metricValues.forEach((el) => animateMetric(el));
      }
    }
    
  });
})(jQuery);

// Read More
const btn=document.getElementById("toggleBtn"),
      text=document.getElementById("myText");

if (btn && text) {
  btn.onclick=()=>{
    text.classList.toggle("expanded");
    btn.textContent=text.classList.contains("expanded")?"READ LESS":"READ MORE";
  };
}

// Consultation Steps
document.addEventListener("DOMContentLoaded", function () {
  const steps = document.querySelectorAll(".step-horizontal");
  const stepDescriptions = document.querySelectorAll(".step-description-wrapper .step-description");
  const prevBtn = document.getElementById("prevBtn");
  const nextBtn = document.getElementById("nextBtn");
  const submitBtn = document.getElementById("submitBtn");
  const submitContent = document.getElementById("consultationSubmitContent");

  if (!steps.length || !prevBtn || !nextBtn) return;

  let currentStep = 1;
  let isSubmitted = false;
  const totalSteps = steps.length;

  const setStepStates = () => {
    steps.forEach((step, index) => {
      if (isSubmitted || index < currentStep - 1) {
        step.classList.add("complete");
        step.classList.remove("active");
        return;
      }
      if (index === currentStep - 1) {
        step.classList.add("active");
        step.classList.remove("complete");
      } else {
        step.classList.remove("active", "complete");
      }
    });
  };

  const setDescriptionState = () => {
    if (!stepDescriptions.length) return;
    stepDescriptions.forEach((panel, index) => {
      const shouldShow = !isSubmitted && index === currentStep - 1;
      panel.classList.toggle("active-step", shouldShow);
    });
  };

  const setButtonStates = () => {
    if (isSubmitted) {
      prevBtn.style.display = "none";
      nextBtn.style.display = "none";
      if (submitBtn) submitBtn.style.display = "none";
      return;
    }
    prevBtn.style.display = currentStep === 1 ? "none" : "";
    if (submitBtn) {
      const isLastStep = currentStep === totalSteps;
      nextBtn.style.display = isLastStep ? "none" : "";
      submitBtn.style.display = isLastStep ? "" : "none";
    }
  };

  const updateSteps = () => {
    setStepStates();
    setDescriptionState();
    setButtonStates();
  };

  prevBtn.addEventListener("click", function () {
    if (currentStep > 1) {
      currentStep--;
      updateSteps();
    }
  });

  nextBtn.addEventListener("click", function () {
    if (currentStep < totalSteps) {
      currentStep++;
      updateSteps();
    }
  });

  if (submitBtn) {
    submitBtn.addEventListener("click", function () {
      isSubmitted = true;
      updateSteps();
      if (submitContent) {
        submitContent.classList.remove("d-none");
      }
    });
  }

  updateSteps();
});