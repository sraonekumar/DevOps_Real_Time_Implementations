import { render, screen } from "@testing-library/react";
import App from "./App";

describe("Sample application test", () => {
  test("App Test", () => {
    // render(<App />)
    expect(2 + 2).toBe(4);
  });
  test("App Test 2", () => {
    // render(<App />)
    expect(2 + 2).toBe(3);
  });
});


