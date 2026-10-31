/**
 * Solavanta Careers - Main Interactive Engine
 * High performance, accessible, zero-dependency JavaScript
 */

document.addEventListener('DOMContentLoaded', () => {

  // =========================================================================
  // 1. DYNAMIC CAREER TRACK DATA & TABS
  // =========================================================================
  const trackData = {
    swe: {
      title: "Software & Full-Stack Systems Accelerator",
      description: "Transform your profile from academic learner to production engineer capable of designing, building, and scaling distributed cloud-native microservices.",
      roles: ["Full Stack Engineer", "Backend Systems Engineer", "Frontend React/Next.js Architect", "API Platform Engineer"],
      skills: ["React 19", "Node.js & Express", "TypeScript", "Go / Java", "PostgreSQL", "Redis Caching", "Docker", "Microservices & gRPC"],
      capstone: "High-Throughput Real-Time FinTech Payment Processor with idempotency keys, distributed lock, and Kafka streaming.",
      avgSalary: "$108,000",
      topSalary: "$182,000",
      avgPlacementDays: "68 Days",
      hiringRate: "92%"
    },
    data: {
      title: "Data Science & Applied AI / ML Accelerator",
      description: "Break into high-paying enterprise data roles. Master predictive statistical modeling, scalable data pipelines, vector databases, and LLM orchestration.",
      roles: ["Machine Learning Engineer", "Data Scientist", "AI Application Developer", "Big Data Engineer"],
      skills: ["Python", "PyTorch / TensorFlow", "LangChain & LlamaIndex", "Vector DBs (Pinecone, Qdrant)", "SQL & Snowflake", "Spark / Databricks", "MLflow", "AWS SageMaker"],
      capstone: "Multi-Agent RAG Orchestration Platform for enterprise document retrieval and real-time semantic synthesis.",
      avgSalary: "$114,000",
      topSalary: "$185,000",
      avgPlacementDays: "74 Days",
      hiringRate: "90%"
    },
    cloud: {
      title: "Cloud Infrastructure, DevOps & SRE Accelerator",
      description: "Become the backbone of modern engineering teams. Specialize in infrastructure as code (IaC), container orchestration, zero-downtime CI/CD, and multi-region resilience.",
      roles: ["Cloud Engineer (AWS/GCP/Azure)", "DevOps Specialist", "Site Reliability Engineer (SRE)", "Platform Infrastructure Lead"],
      skills: ["AWS Solutions Architecture", "Kubernetes (K8s)", "Terraform IaC", "GitHub Actions & ArgoCD", "Prometheus & Grafana", "Linux Kernel & Networking", "Zero-Trust Security"],
      capstone: "Self-Healing Multi-Cluster Kubernetes Mesh with automated canary deployments and SOC2 compliance monitoring.",
      avgSalary: "$112,000",
      topSalary: "$176,000",
      avgPlacementDays: "62 Days",
      hiringRate: "94%"
    },
    analytics: {
      title: "Business Intelligence & Strategic Product Analytics",
      description: "Bridge raw corporate data with strategic executive decisions. Master complex SQL, statistical forecasting, metric trees, and interactive executive dashboards.",
      roles: ["Business Intelligence Engineer", "Product Data Analyst", "Strategic Analytics Manager", "Data Ops Analyst"],
      skills: ["Advanced SQL & dbt", "Tableau & PowerBI", "A/B Testing & Causal Inference", "Python (Pandas, Scikit-learn)", "Google BigQuery", "Financial Modeling"],
      capstone: "End-to-End SaaS Unit Economics & Churn Propensity Engine with automated cohort anomaly detection.",
      avgSalary: "$92,000",
      topSalary: "$145,000",
      avgPlacementDays: "58 Days",
      hiringRate: "91%"
    }
  };

  const trackDisplay = document.getElementById('trackCard');
  const trackTabs = document.querySelectorAll('.track-tab');

  function renderTrack(trackKey) {
    const data = trackData[trackKey] || trackData.swe;
    trackDisplay.style.opacity = '0';

    setTimeout(() => {
      trackDisplay.innerHTML = `
        <div class="track-inner-grid">
          <div class="track-info">
            <span class="pill-badge pill-emerald">${data.roles[0]} Pathway</span>
            <h3>${data.title}</h3>
            <p>${data.description}</p>

            <div class="track-details-block">
              <h4>Target Job Titles</h4>
              <div class="tech-tag-row">
                ${data.roles.map(r => `<span class="tech-tag">${r}</span>`).join('')}
              </div>
            </div>

            <div class="track-details-block">
              <h4>Core Technology & Stack</h4>
              <div class="tech-tag-row">
                ${data.skills.map(s => `<span class="tech-tag">${s}</span>`).join('')}
              </div>
            </div>

            <div class="track-details-block">
              <h4>Flagship Portfolio Capstone Architecture</h4>
              <p style="font-size: 0.875rem; color: #334155; background: #F8FAFC; padding: 12px; border-radius: 8px; border: 1px solid #E2E8F0;">
                🏗️ <strong>${data.capstone}</strong>
              </p>
            </div>
          </div>

          <div class="track-sidebar-stats">
            <div>
              <div class="side-stat-row">
                <span class="side-stat-label">Average Starting Base:</span>
                <span class="side-stat-value text-emerald">${data.avgSalary}</span>
              </div>
              <div class="side-stat-row">
                <span class="side-stat-label">Top Reported Offer:</span>
                <span class="side-stat-value">${data.topSalary}</span>
              </div>
              <div class="side-stat-row">
                <span class="side-stat-label">Avg. Interview Timeline:</span>
                <span class="side-stat-value">${data.avgPlacementDays}</span>
              </div>
              <div class="side-stat-row">
                <span class="side-stat-label">Placement Success Rate:</span>
                <span class="side-stat-value">${data.hiringRate}</span>
              </div>
            </div>

            <div style="margin-top: 24px;">
              <button class="btn btn-primary btn-block" data-open-modal="bookingModal">
                Apply for this Track &rarr;
              </button>
            </div>
          </div>
        </div>
      `;
      trackDisplay.style.opacity = '1';
    }, 150);
  }

  trackTabs.forEach(tab => {
    tab.addEventListener('click', () => {
      trackTabs.forEach(t => {
        t.classList.remove('active');
        t.setAttribute('aria-selected', 'false');
      });
      tab.classList.add('active');
      tab.setAttribute('aria-selected', 'true');
      const trackKey = tab.getAttribute('data-track');
      renderTrack(trackKey);
    });
  });

  // Render initial track
  renderTrack('swe');


  // =========================================================================
  // 2. SALARY & ROI CALCULATOR
  // =========================================================================
  const salaryRange = document.getElementById('salaryRange');
  const salaryDisplay = document.getElementById('salaryDisplay');
  const visaSelect = document.getElementById('visaSelect');
  const fieldSelect = document.getElementById('fieldSelect');

  const projectedSalaryEl = document.getElementById('projectedSalary');
  const salaryIncreaseText = document.getElementById('salaryIncreaseText');
  const projectedTimelineEl = document.getElementById('projectedTimeline');
  const projectedRoiEl = document.getElementById('projectedRoi');

  function calculateForecast() {
    const currentVal = parseInt(salaryRange.value, 10);
    salaryDisplay.textContent = `$${currentVal.toLocaleString()} / yr`;

    // Multiplier based on domain
    let fieldMultiplier = 1.35;
    if (fieldSelect.value === 'data') fieldMultiplier = 1.45;
    else if (fieldSelect.value === 'cloud') fieldMultiplier = 1.42;
    else if (fieldSelect.value === 'swe') fieldMultiplier = 1.38;
    else if (fieldSelect.value === 'bi') fieldMultiplier = 1.28;

    // Projected package
    let projectedBase = Math.round(Math.max(currentVal * fieldMultiplier, 92000) / 1000) * 1000;
    let diff = projectedBase - currentVal;
    if (diff < 15000) {
      projectedBase = currentVal + 22000;
      diff = 22000;
    }

    // 3 Year compounding value
    const threeYearGain = diff * 3;

    // Timeline based on visa urgency
    let timeline = "60 - 90 Days";
    if (visaSelect.value === 'opt') timeline = "45 - 75 Days";
    else if (visaSelect.value === 'stem') timeline = "60 - 90 Days";
    else if (visaSelect.value === 'h1b') timeline = "60 - 100 Days";

    projectedSalaryEl.textContent = `$${projectedBase.toLocaleString()}`;
    salaryIncreaseText.textContent = `+$${diff.toLocaleString()} projected annual lift`;
    projectedTimelineEl.textContent = timeline;
    projectedRoiEl.textContent = `+$${threeYearGain.toLocaleString()}`;
  }

  if (salaryRange && visaSelect && fieldSelect) {
    salaryRange.addEventListener('input', calculateForecast);
    visaSelect.addEventListener('change', calculateForecast);
    fieldSelect.addEventListener('change', calculateForecast);
    calculateForecast();
  }


  // =========================================================================
  // 3. FAQS ACCORDION
  // =========================================================================
  const accordionItems = document.querySelectorAll('.accordion-item');

  accordionItems.forEach(item => {
    const header = item.querySelector('.accordion-header');
    header.addEventListener('click', () => {
      const isActive = item.classList.contains('active');

      // Close all
      accordionItems.forEach(i => {
        i.classList.remove('active');
        i.querySelector('.accordion-header').setAttribute('aria-expanded', 'false');
      });

      // Toggle current
      if (!isActive) {
        item.classList.add('active');
        header.setAttribute('aria-expanded', 'true');
      }
    });
  });


  // =========================================================================
  // 4. MODALS ENGINE
  // =========================================================================
  const openModalButtons = document.querySelectorAll('[data-open-modal]');
  const closeModalButtons = document.querySelectorAll('[data-close-modal]');
  const modals = document.querySelectorAll('.modal-backdrop');

  function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
      modal.classList.add('open');
      modal.setAttribute('aria-hidden', 'false');
      document.body.style.overflow = 'hidden';
    }
  }

  function closeModal(modal) {
    modal.classList.remove('open');
    modal.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
  }

  openModalButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const modalId = btn.getAttribute('data-open-modal');
      openModal(modalId);
    });
  });

  closeModalButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const modal = btn.closest('.modal-backdrop');
      if (modal) closeModal(modal);
    });
  });

  // Close when clicking backdrop outside dialog
  modals.forEach(modal => {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        closeModal(modal);
      }
    });
  });

  // Video trigger preview click
  const videoTrigger = document.getElementById('videoTrigger');
  if (videoTrigger) {
    videoTrigger.addEventListener('click', () => {
      openModal('videoModal');
    });
  }

  // Escape key to close
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      modals.forEach(modal => {
        if (modal.classList.contains('open')) closeModal(modal);
      });
    }
  });


  // =========================================================================
  // 5. TOAST NOTIFICATIONS HELPER
  // =========================================================================
  const toastContainer = document.getElementById('toastContainer');

  function showToast(title, message, icon = '🎉') {
    if (!toastContainer) return;
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `
      <span style="font-size: 1.25rem;">${icon}</span>
      <div>
        <strong style="display:block; font-size: 0.875rem;">${title}</strong>
        <span style="font-size: 0.8125rem; color: #CBD5E1;">${message}</span>
      </div>
    `;
    toastContainer.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateX(100%)';
      toast.style.transition = 'all 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 4500);
  }


  // =========================================================================
  // 6. FORM HANDLERS (BOOKING, HANDBOOK, INLINE INTAKE)
  // =========================================================================
  const bookingForm = document.getElementById('bookingForm');
  if (bookingForm) {
    bookingForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const firstName = document.getElementById('bookFirstName').value;
      const modal = bookingForm.closest('.modal-backdrop');
      if (modal) closeModal(modal);
      bookingForm.reset();

      showToast(
        `Application Submitted, ${firstName}!`,
        "An executive career advisor will text/email you within 4 hours to confirm your strategy call.",
        '🚀'
      );
    });
  }

  const handbookForm = document.getElementById('handbookForm');
  if (handbookForm) {
    handbookForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const email = document.getElementById('hbEmail').value;
      const modal = handbookForm.closest('.modal-backdrop');
      if (modal) closeModal(modal);
      handbookForm.reset();

      // Trigger synthetic download
      const dummyLink = document.createElement('a');
      dummyLink.href = 'data:text/plain;charset=utf-8,' + encodeURIComponent(
        "SOLAVANTA CAREERS - 2026 OFFICIAL PLACEMENT HANDBOOK\n" +
        "====================================================\n" +
        "1. OPT & STEM OPT Compliance Guide (Form I-983 Checklist)\n" +
        "2. High-Signal Tech Resume & Production GitHub Architectures\n" +
        "3. System Design & Coding Interview Question Bank\n" +
        "4. Negotiation Playbook: Turning $80k Offers into $115k+ Packages\n\n" +
        "Welcome to Solavanta Careers! Your journey to a sponsored tech career begins now."
      );
      dummyLink.setAttribute('download', 'Solavanta_Careers_2026_Handbook.txt');
      document.body.appendChild(dummyLink);
      dummyLink.click();
      dummyLink.remove();

      showToast(
        "Handbook Download Started!",
        `We've also dispatched a copy to ${email}. Check your inbox!`,
        '📄'
      );
    });
  }

  const quickForm = document.getElementById('heroQuickForm');
  if (quickForm) {
    quickForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const name = document.getElementById('qName').value;
      quickForm.reset();

      showToast(
        `Diagnostic Request Received, ${name}!`,
        "Our admissions committee is reviewing your eligibility. Expect a response today.",
        '✅'
      );
    });
  }


  // =========================================================================
  // 7. ANIMATED NUMBER COUNTERS (INTERSECTION OBSERVER)
  // =========================================================================
  const counterElements = document.querySelectorAll('.counter');
  let hasCounted = false;

  const countObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting && !hasCounted) {
        hasCounted = true;
        counterElements.forEach(el => {
          const target = parseInt(el.getAttribute('data-target'), 10);
          const duration = 1800; // ms
          const stepTime = 30;
          const totalSteps = duration / stepTime;
          const increment = target / totalSteps;
          let current = 0;

          const timer = setInterval(() => {
            current += increment;
            if (current >= target) {
              el.textContent = target.toLocaleString();
              clearInterval(timer);
            } else {
              el.textContent = Math.floor(current).toLocaleString();
            }
          }, stepTime);
        });
      }
    });
  }, { threshold: 0.3 });

  const metricsCard = document.querySelector('.metrics-card');
  if (metricsCard) {
    countObserver.observe(metricsCard);
  }


  // =========================================================================
  // 8. LIVE ACTIVITY TICKER PILL (ROTATING NOTIFICATIONS)
  // =========================================================================
  const activityText = document.getElementById('liveActivityText');
  const activities = [
    "Recent Match: Sneha landed interview @ Salesforce (San Francisco)",
    "Offer Letter: Aryan accepted $118k Data Engineer role @ Capital One",
    "Screening Scheduled: Rohan with Bloomberg for Backend SWE",
    "Visa Sponsoring Offer: Priya signed $105k Cloud Architect role @ Deloitte",
    "New Cohort: 4 spots remaining for Fall 2026 Mentorship Group"
  ];
  let activityIdx = 0;

  if (activityText) {
    setInterval(() => {
      activityIdx = (activityIdx + 1) % activities.length;
      activityText.style.opacity = '0';
      setTimeout(() => {
        activityText.textContent = activities[activityIdx];
        activityText.style.opacity = '1';
        activityText.style.transition = 'opacity 0.4s ease';
      }, 400);
    }, 6000);
  }


  // =========================================================================
  // 9. STICKY NAVBAR & MOBILE MENU
  // =========================================================================
  const navbar = document.getElementById('navbar');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 30) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  });

  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const mobileNav = document.getElementById('mobileNav');
  const mobileLinks = document.querySelectorAll('.mobile-link');

  if (mobileMenuBtn && mobileNav) {
    mobileMenuBtn.addEventListener('click', () => {
      mobileMenuBtn.classList.toggle('active');
      mobileNav.classList.toggle('open');
    });

    mobileLinks.forEach(link => {
      link.addEventListener('click', () => {
        mobileMenuBtn.classList.remove('active');
        mobileNav.classList.remove('open');
      });
    });
  }

  // Dynamic Year in footer
  const yearEl = document.getElementById('currentYear');
  if (yearEl) {
    yearEl.textContent = new Date().getFullYear();
  }

});
