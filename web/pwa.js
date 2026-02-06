(function () {
  let deferredPrompt;
  let banner;

  function createBanner() {
    if (banner) return;
    banner = document.createElement('div');
    banner.style.position = 'fixed';
    banner.style.bottom = '16px';
    banner.style.left = '50%';
    banner.style.transform = 'translateX(-50%)';
    banner.style.background = 'rgba(15, 15, 35, 0.95)';
    banner.style.color = '#fff';
    banner.style.padding = '16px 20px';
    banner.style.borderRadius = '16px';
    banner.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.35)';
    banner.style.display = 'flex';
    banner.style.alignItems = 'center';
    banner.style.gap = '12px';
    banner.style.zIndex = '9999';

    const text = document.createElement('span');
    text.textContent = 'Install jCharade for a full-screen experience';
    text.style.fontFamily = 'sans-serif';
    text.style.fontSize = '15px';

    const button = document.createElement('button');
    button.textContent = 'Install';
    button.style.background = '#FFD700';
    button.style.border = 'none';
    button.style.color = '#0f0f23';
    button.style.fontWeight = '600';
    button.style.padding = '10px 18px';
    button.style.borderRadius = '999px';
    button.style.cursor = 'pointer';
    button.style.fontFamily = 'inherit';

    button.addEventListener('click', async () => {
      if (!deferredPrompt) return;
      button.disabled = true;
      banner.style.opacity = '0.6';
      deferredPrompt.prompt();
      const choice = await deferredPrompt.userChoice;
      if (choice.outcome === 'accepted') {
        hideBanner();
      } else {
        button.disabled = false;
        banner.style.opacity = '1';
      }
    });

    const dismiss = document.createElement('button');
    dismiss.textContent = 'Maybe later';
    dismiss.style.background = 'transparent';
    dismiss.style.border = 'none';
    dismiss.style.color = '#ccc';
    dismiss.style.fontFamily = 'inherit';
    dismiss.style.cursor = 'pointer';

    dismiss.addEventListener('click', hideBanner);

    banner.appendChild(text);
    banner.appendChild(button);
    banner.appendChild(dismiss);
    document.body.appendChild(banner);
  }

  function hideBanner() {
    if (banner && banner.parentNode) {
      banner.parentNode.removeChild(banner);
    }
    banner = null;
    deferredPrompt = null;
  }

  window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    deferredPrompt = event;
    createBanner();
  });

  window.addEventListener('appinstalled', hideBanner);
})();
