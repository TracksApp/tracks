const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Listen to all network requests
  page.on('request', request => {
    console.log('REQUEST:', request.method(), request.url());
    if (request.method() === 'POST') {
      console.log('POST DATA:', request.postData());
      console.log('HEADERS:', JSON.stringify(request.headers(), null, 2));
    }
  });

  page.on('response', response => {
    console.log('RESPONSE:', response.status(), response.url());
  });

  // Navigate to login page
  console.log('\n=== Navigating to login page ===');
  await page.goto('http://localhost:8080/login');

  // Take screenshot of login page
  await page.screenshot({ path: '/tmp/login-page.png' });
  console.log('Screenshot saved to /tmp/login-page.png');

  // Check form fields
  const loginInput = await page.locator('input[name="login"]');
  const passwordInput = await page.locator('input[name="password"]');
  const submitButton = await page.locator('button[type="submit"]');

  console.log('\n=== Form elements found ===');
  console.log('Login input exists:', await loginInput.count() > 0);
  console.log('Password input exists:', await passwordInput.count() > 0);
  console.log('Submit button exists:', await submitButton.count() > 0);

  // Fill in the form
  console.log('\n=== Filling form with admin/admin ===');
  await loginInput.fill('admin');
  await passwordInput.fill('admin');

  // Get form action
  const form = await page.locator('form');
  const formAction = await form.getAttribute('action');
  const formMethod = await form.getAttribute('method');
  console.log('Form action:', formAction);
  console.log('Form method:', formMethod);

  // Submit the form
  console.log('\n=== Submitting form ===');
  await submitButton.click();

  // Wait a bit for response
  await page.waitForTimeout(2000);

  // Check current URL
  console.log('\n=== After form submission ===');
  console.log('Current URL:', page.url());

  // Check for error messages
  const errorElement = await page.locator('.alert-error');
  if (await errorElement.count() > 0) {
    const errorText = await errorElement.textContent();
    console.log('ERROR MESSAGE:', errorText);
  }

  // Take screenshot after submission
  await page.screenshot({ path: '/tmp/after-login.png' });
  console.log('Screenshot saved to /tmp/after-login.png');

  // Get page content
  const pageContent = await page.content();
  console.log('\n=== Page title ===');
  console.log(await page.title());

  await browser.close();
})();
