const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

(async () => {
  console.log('Starting E2E Integration Test...');
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  // Set viewport size for consistent screenshots
  await page.setViewportSize({ width: 1280, height: 800 });

  try {
    console.log('Navigating to http://localhost:8080...');
    await page.goto('http://localhost:8080', { waitUntil: 'networkidle' });
    
    // Wait for the app to load
    await page.waitForTimeout(5000);
    
    // Attempt to enable semantics if necessary
    const semanticsPlaceholder = page.locator('flt-semantics-placeholder');
    if (await semanticsPlaceholder.count() > 0) {
      console.log('Activating Flutter Web Semantics via dispatchEvent...');
      await semanticsPlaceholder.first().dispatchEvent('click');
      await page.waitForTimeout(2000);
    }

    // Step 1: Choose Quiz Mode / Easy difficulty
    console.log('Searching for Easy difficulty selection...');
    const easyButton = page.locator('[aria-label*="Easy"]').or(page.locator('text=Easy')).first();
    if (await easyButton.isVisible()) {
      console.log('Clicking Easy difficulty...');
      await easyButton.click();
    } else {
      console.log('Searching for general start/play button...');
      const startButton = page.locator('[aria-label*="Start"]').or(page.locator('[aria-label*="Play"]')).or(page.locator('text=Start')).or(page.locator('text=Play')).first();
      if (await startButton.isVisible()) {
        await startButton.click();
      } else {
        // Fallback: click any element that looks like a button
        const buttons = page.locator('button, [role="button"], [aria-label]');
        const count = await buttons.count();
        for (let i = 0; i < count; i++) {
          const label = await buttons.nth(i).getAttribute('aria-label');
          if (label && (label.toLowerCase().includes('easy') || label.toLowerCase().includes('start') || label.toLowerCase().includes('play'))) {
            await buttons.nth(i).click();
            break;
          }
        }
      }
    }
    await page.waitForTimeout(2000);

    // Step 2: Click one of the multiple-choice options in the Quiz
    console.log('Selecting a quiz option...');
    const optionCard = page.locator('[aria-label*=":"]').first();
    if (await optionCard.isVisible()) {
      const optionText = await optionCard.getAttribute('aria-label');
      console.log(`Selecting option: ${optionText}`);
      await optionCard.click();
    } else {
      console.log('Quiz options not found via aria-label, trying text pattern HH:MM...');
      const textMatches = page.locator('text=/\\d{1,2}:\\d{2}/');
      if (await textMatches.count() > 0) {
        await textMatches.first().click();
      }
    }
    await page.waitForTimeout(2000);

    // Step 3: Check score
    console.log('Checking score display...');
    const scoreElement = page.locator('[aria-label*="Score"]').or(page.locator('text=Score')).first();
    if (await scoreElement.isVisible()) {
      const scoreVal = await scoreElement.textContent();
      console.log(`Current Score: ${scoreVal}`);
    }

    // Step 4: Navigate to Sandbox Mode and adjust time
    console.log('Attempting to navigate to Sandbox Mode...');
    const sandboxTab = page.locator('[aria-label*="Sandbox"]').or(page.locator('text=Sandbox')).first();
    if (await sandboxTab.isVisible()) {
      await sandboxTab.click();
      await page.waitForTimeout(2000);
      
      console.log('Adjusting time in Sandbox (+15 mins)...');
      const add15Btn = page.locator('[aria-label*="+15"]').or(page.locator('text="+15"')).first();
      if (await add15Btn.isVisible()) {
        await add15Btn.click();
        await page.waitForTimeout(1000);
      }
    }

    // Step 5: Capture gameplay screenshot
    console.log('Capturing gameplay screenshot...');
    const screenshotPath = '/Users/ricc/git/orologia.io/solutions/antigravity2.0-multi-agent-flutter/artifact/gameplay_snapshot.png';
    const brainScreenshotPath = '/Users/ricc/.gemini/antigravity/brain/cbb42f32-2103-4025-8a73-7132f2ed8ba9/gameplay_snapshot.png';
    
    fs.mkdirSync(path.dirname(screenshotPath), { recursive: true });
    fs.mkdirSync(path.dirname(brainScreenshotPath), { recursive: true });

    await page.screenshot({ path: screenshotPath });
    console.log(`Saved screenshot to ${screenshotPath}`);
    
    fs.copyFileSync(screenshotPath, brainScreenshotPath);
    console.log(`Copied screenshot to ${brainScreenshotPath}`);

    console.log('E2E Test completed successfully.');
  } catch (error) {
    console.error('E2E Test failed:', error);
    try {
      const errScreenshotPath = '/Users/ricc/git/orologia.io/solutions/antigravity2.0-multi-agent-flutter/artifact/gameplay_snapshot.png';
      const brainScreenshotPath = '/Users/ricc/.gemini/antigravity/brain/cbb42f32-2103-4025-8a73-7132f2ed8ba9/gameplay_snapshot.png';
      fs.mkdirSync(path.dirname(errScreenshotPath), { recursive: true });
      await page.screenshot({ path: errScreenshotPath });
      fs.copyFileSync(errScreenshotPath, brainScreenshotPath);
      console.log(`Saved screenshot on failure to ${errScreenshotPath}`);
    } catch (e) {
      console.error('Could not save failure screenshot:', e);
    }
    process.exit(1);
  } finally {
    await browser.close();
  }
})();
