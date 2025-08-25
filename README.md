# 🧱 CS50 — Breakout

**Course:** [CS50's Introduction to Game Development](https://cs50.harvard.edu/games/)  
**Assignment:** Breakout  
**Engine / Language:** LÖVE2D (Lua)  

---

## 📋 Project Overview

This repository contains my implementation of the **Breakout** assignment from CS50's Introduction to Game Development.  
📺 You can also watch my gameplay demo on [YouTube](https://youtu.be/iXx1497JTpE?si=Prg1LnJX3ffYVyP2).

---

### What I implemented:

- ✔️ Added a **Powerup** that spawns **two extra Balls**.  
- ✔️ Implemented **Paddle growth/shrink mechanics**:
  - Paddle shrinks when losing a life.  
  - Paddle grows when reaching certain score thresholds.  
- ✔️ Introduced a **Locked Brick**:
  - Can only be broken by collecting the **Key Powerup**.  
  - Key spawns randomly when locked bricks exist, similar to Ball Powerup.  
- ✔️ Balanced gameplay by resetting balls upon entering the **Victory State**.  

---

## 🎬 Gameplay Preview

![Gameplay Preview](docs/gameplay.gif)

---

## 🚀 How to Run

1. Install [LÖVE2D](https://love2d.org/).  

2. Clone this repository:

   ```bash
   git clone https://github.com/huzaifa-gamedev/cs50-breakout.git
   cd cs50-breakout
   ```

3. Run the game:

   ```bash
   love .
   ```

---

## 🎯 Controls

- **Enter** — Start the game / Serve the ball  
- **← / → (Arrow Keys)** — Move Paddle  
- **Escape** — Quit game  

---

## ✨ Credits

- Original skeleton code & assets: CS50's Introduction to Game Development (Harvard). Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).  

---

## 📄 License

- This implementation: © 2025 Muhammad Huzaifa Karim. Licensed under the [MIT License](LICENSE).  

For more details, see [ATTRIBUTION.md](ATTRIBUTION.md).  

---

## ✍️ Author

**Muhammad Huzaifa Karim**  
[GitHub Profile](https://github.com/huzaifakarim1)  

---

## 📬 Contact

For ideas, feedback, or collaboration, feel free to reach out via [GitHub](https://github.com/huzaifakarim1).  

---

© 2025 Muhammad Huzaifa Karim. All rights reserved.
