const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8080';
const USERNAME = 'admin';
const PASSWORD = 'admin';

async function main() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  let testsPassed = 0;
  let testsFailed = 0;

  // Helper function to log test results
  function logTest(name, passed, error = null) {
    if (passed) {
      console.log(`✓ ${name}`);
      testsPassed++;
    } else {
      console.log(`✗ ${name}`);
      if (error) console.log(`  Error: ${error}`);
      testsFailed++;
    }
  }

  try {
    console.log('\n=== Starting Tracks CRUD Tests ===\n');

    // Test 1: Login with default credentials
    console.log('Test 1: Login with admin/admin');
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[name="login"]', USERNAME);
    await page.fill('input[name="password"]', PASSWORD);
    await page.click('button[type="submit"]');
    await page.waitForTimeout(1000);

    const currentUrl = page.url();
    const isLoggedIn = currentUrl.includes('/dashboard') || currentUrl === `${BASE_URL}/` || await page.locator('text=Dashboard').count() > 0;
    logTest('Login successful', isLoggedIn);

    if (!isLoggedIn) {
      console.log('Current URL:', currentUrl);
      throw new Error('Login failed - cannot continue tests');
    }

    // Test 2: Navigate to Contexts page
    console.log('\nTest 2: Navigate to Contexts page');
    await page.click('a[href="/contexts"]');
    await page.waitForTimeout(500);
    const onContextsPage = await page.locator('h2:has-text("Contexts")').count() > 0;
    logTest('Navigate to Contexts page', onContextsPage);

    // Test 3: Create a new context
    console.log('\nTest 3: Create a new context');
    const contextName = `@test-context-${Date.now()}`;
    await page.click('button:has-text("New Context")');
    await page.waitForTimeout(300);
    await page.fill('input[name="name"]', contextName);
    await page.click('button[type="submit"]:has-text("Create Context")');
    await page.waitForTimeout(1000);

    const contextCreated = await page.locator(`text=${contextName}`).count() > 0;
    logTest(`Create context: ${contextName}`, contextCreated);

    // Get the context ID for later use
    let contextId = null;
    if (contextCreated) {
      const contextCard = await page.locator(`.context-card:has-text("${contextName}")`).first();
      const deleteForm = await contextCard.locator('form[action*="/contexts/"]').first();
      const action = await deleteForm.getAttribute('action');
      const match = action.match(/\/contexts\/(\d+)\/delete/);
      if (match) {
        contextId = match[1];
        console.log(`  Context ID: ${contextId}`);
      }
    }

    // Test 4: Navigate to Todos page
    console.log('\nTest 4: Navigate to Todos page');
    await page.click('a[href="/todos"]');
    await page.waitForTimeout(500);
    const onTodosPage = await page.locator('h2:has-text("Todos")').count() > 0;
    logTest('Navigate to Todos page', onTodosPage);

    // Test 5: Create a new todo with the context
    console.log('\nTest 5: Create a new todo with context assignment');
    const todoDescription = `Test todo ${Date.now()}`;
    await page.click('button:has-text("New Todo")');
    await page.waitForTimeout(300);
    await page.fill('input[name="description"]', todoDescription);
    await page.selectOption('select[name="context_id"]', { label: contextName });
    await page.fill('textarea[name="notes"]', 'This is a test todo created by Playwright');
    await page.click('button[type="submit"]:has-text("Create Todo")');
    await page.waitForTimeout(1000);

    const todoCreated = await page.locator(`text=${todoDescription}`).count() > 0;
    logTest(`Create todo: ${todoDescription}`, todoCreated);

    // Verify the todo has the correct context
    if (todoCreated) {
      const todoItem = await page.locator(`.todo-item:has-text("${todoDescription}")`).first();
      const hasContext = await todoItem.locator(`text=${contextName}`).count() > 0;
      logTest(`Todo has correct context: ${contextName}`, hasContext);
    }

    // Get the todo ID for later use
    let todoId = null;
    if (todoCreated) {
      const todoItem = await page.locator(`.todo-item:has-text("${todoDescription}")`).first();
      const deleteForm = await todoItem.locator('form[action*="/todos/"]').first();
      const action = await deleteForm.getAttribute('action');
      const match = action.match(/\/todos\/(\d+)\/delete/);
      if (match) {
        todoId = match[1];
        console.log(`  Todo ID: ${todoId}`);
      }
    }

    // Test 6: Verify RSS feed for the context
    console.log('\nTest 6: Retrieve RSS feed for context');
    if (contextId) {
      const feedUrl = `${BASE_URL}/contexts/${contextId}/feed.rss`;
      console.log(`  Feed URL: ${feedUrl}`);

      const feedResponse = await page.goto(feedUrl);
      const feedContent = await feedResponse.text();

      const isValidRSS = feedContent.includes('<?xml') &&
                         feedContent.includes('<rss') &&
                         feedContent.includes(contextName);
      logTest('RSS feed is valid XML', isValidRSS);

      const containsTodo = feedContent.includes(todoDescription);
      logTest('RSS feed contains the todo', containsTodo);

      // Save RSS feed for inspection
      const fs = require('fs');
      fs.writeFileSync('/tmp/context-feed.xml', feedContent);
      console.log('  RSS feed saved to: /tmp/context-feed.xml');
    } else {
      logTest('RSS feed test (skipped - no context ID)', false, 'Context ID not found');
    }

    // Test 7: Delete the todo
    console.log('\nTest 7: Delete the todo');
    await page.goto(`${BASE_URL}/todos`);
    await page.waitForTimeout(500);

    if (todoCreated && todoId) {
      // Set up dialog handler for confirmation
      page.once('dialog', dialog => {
        console.log(`  Confirmation dialog: ${dialog.message()}`);
        dialog.accept();
      });

      const todoItem = await page.locator(`.todo-item:has-text("${todoDescription}")`).first();
      const deleteButton = await todoItem.locator('button:has-text("Delete")').first();
      await deleteButton.click();
      await page.waitForTimeout(1000);

      const todoDeleted = await page.locator(`text=${todoDescription}`).count() === 0;
      logTest(`Delete todo: ${todoDescription}`, todoDeleted);
    } else {
      logTest('Delete todo (skipped - todo not found)', false);
    }

    // Test 8: Delete the context
    console.log('\nTest 8: Delete the context');
    await page.goto(`${BASE_URL}/contexts`);
    await page.waitForTimeout(500);

    if (contextCreated) {
      // Set up dialog handler for confirmation
      page.once('dialog', dialog => {
        console.log(`  Confirmation dialog: ${dialog.message()}`);
        dialog.accept();
      });

      const contextCard = await page.locator(`.context-card:has-text("${contextName}")`).first();
      const deleteButton = await contextCard.locator('button:has-text("Delete")').first();
      await deleteButton.click();
      await page.waitForTimeout(1000);

      const contextDeleted = await page.locator(`text=${contextName}`).count() === 0;
      logTest(`Delete context: ${contextName}`, contextDeleted);
    } else {
      logTest('Delete context (skipped - context not found)', false);
    }

    // Test 9: Verify context RSS feed returns 404 after deletion
    console.log('\nTest 9: Verify RSS feed returns error after context deletion');
    if (contextId) {
      const feedUrl = `${BASE_URL}/contexts/${contextId}/feed.rss`;
      try {
        const feedResponse = await page.goto(feedUrl);
        const status = feedResponse.status();
        const feedGone = status === 404 || status === 302; // 302 is redirect to error page
        logTest('RSS feed returns error after deletion', feedGone);
      } catch (error) {
        logTest('RSS feed returns error after deletion', true);
      }
    } else {
      logTest('RSS feed deletion test (skipped - no context ID)', false);
    }

    // Summary
    console.log('\n=== Test Summary ===');
    console.log(`Tests Passed: ${testsPassed}`);
    console.log(`Tests Failed: ${testsFailed}`);
    console.log(`Total Tests: ${testsPassed + testsFailed}`);

    if (testsFailed === 0) {
      console.log('\n✓ All tests passed!');
    } else {
      console.log('\n✗ Some tests failed!');
    }

  } catch (error) {
    console.error('\n✗ Test suite failed with error:');
    console.error(error);
    testsFailed++;
  } finally {
    await browser.close();
    process.exit(testsFailed > 0 ? 1 : 0);
  }
}

main();
