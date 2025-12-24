Project Title: Smart Camera Recommender System (MATLAB)

1. Project Overview
The Smart Camera Recommender System is a MATLAB-based application designed to assist users in selecting the ideal digital camera based on their specific needs and financial constraints. By leveraging a dataset of modern camera specifications (price, resolution, weight, etc.), the system uses data processing techniques and a user-friendly Graphical User Interface (GUI) to filter, rank, and recommend the best options for Photography, Videography, or Hybrid use.

2. Key FeaturesInteractive
  GUI: A clean, modern interface built with MATLAB's uifigure that allows users to easily input their budget and intended usage.

  Intelligent Data Parsing: Automatically cleans raw data, standardizes column names, and handles missing information (e.g., inferring camera categories from model names).
  
  Custom Recommendation Logic: Uses a weighted scoring algorithm that balances high technical specifications (like Resolution) against cost-efficiency to find the best "value
  for-money" device.
 
  Visual Data Analysis: Includes backend capabilities for clustering cameras using Fuzzy C-Means (FCM) and visualizing market segments via Principal Component Analysis (PCA).

4. Technical Architecture
  A. Data Preprocessing Module
  Input: Loads a raw xlsx dataset (modern_camera_datase.xlsx).

  Cleaning: Renames inconsistent headers (e.g., Weight_inc_Batteries to Weight_g), converts data types, and removes invalid rows.

  Feature Engineering:
  Category Inference: Since the raw data lacks explicit categories, the system uses keyword matching algorithms to classify cameras.
  
  Resolution Normalization: Standardizes resolution metrics into Megapixels (MP) for consistent comparison.

B. Recommendation Engine
Filtering: Narrows down the dataset based on the user's maximum budget and selected category (Photo/Hybrid/Video).

Scoring Algorithm: Ranks the filtered candidates using a composite score

C. Graphical User Interface (GUI)
Inputs:
  Numeric Field: For defining the maximum budget (USD).

  Dropdown Menu: For selecting the primary use case (Photography, Hybrid, or Video).

Outputs:
  Displays the top recommended model name, price, resolution, and weight.Provides a calculated "Match Score" out of 10.

4. How to Run the Project

  Setup: Ensure MATLAB is installed and the file modern_camera_datase.xlsx is in the working directory.
  
  Launch: Run the camera_gui_app.m script.
  
  Interact:
    Enter a budget (e.g., 2000).
    Select a usage type (e.g., Hybrid).
    Click "Find Camera".
    
  Result: The system instantly processes the dataset and displays the best matching camera in the text area.

6. Potential Future Improvements

   Advanced Fuzzy Logic: Fully integrating the Fuzzy Inference System (FIS) into the GUI to handle vague inputs (e.g., "I want something somewhat cheap but very light").

   Web Scraping: Connecting to live APIs to fetch real-time pricing and availability.

   Image Comparisons: Displaying sample images or product photos for the recommended cameras.
