function camera_gui_app
    % CAMERA_GUI_APP Creates a GUI for Camera Recommendation
    % Ensure 'modern_camera_dataset_1_.csv' is in your MATLAB Current Folder.

    %% 1. DATA LOADING & PREPROCESSING
    % Note: Make sure the filename matches your actual file exactly
    filename = 'modern_camera_datase.xlsx'; 
    
    if ~isfile(filename)
        % Fallback if the user renamed it or it's different
        if isfile('modern_camera_datase.xlsx')
            filename = 'modern_camera_datase.xlsx';
        else
            uialert(uifigure, ['File not found: ' filename], 'Error');
            return;
        end
    end

    opts = detectImportOptions(filename);
    opts.VariableNamingRule = 'preserve';
    data = readtable(filename, opts);
    
    % Standardize names
    data.Properties.VariableNames = matlab.lang.makeValidName(data.Properties.VariableNames);
    
    % Map Columns
    if any(strcmp(data.Properties.VariableNames, 'Weight_inc_Batteries_'))
        data.Weight_g_ = data.Weight_inc_Batteries_;
    end
    
    % Handle Resolution
    if any(strcmp(data.Properties.VariableNames, 'EffectivePixels'))
        data.MaxResolution = data.EffectivePixels;
    else
        % Fallback calculation if EffectivePixels is missing
        if any(strcmp(data.Properties.VariableNames, 'Max_resolution'))
             data.MaxResolution = (data.Max_resolution.^2 / 1.5) / 1e6;
        else
             data.MaxResolution = zeros(height(data),1);
        end
    end
    
    % Infer Categories
    data.BetterForCode = zeros(height(data), 1);
    
    for i = 1:height(data)
        if iscell(data.Model)
            name = lower(data.Model{i});
        else
            name = lower(string(data.Model(i)));
        end
        
        % Infer Usage
        if contains(name, {'gopro', 'osmo', 'fx3', 'gh6', 'action'})
            data.BetterForCode(i) = 3; % Video
        elseif contains(name, {'gfx', 'z9', 'r5', 'd780'})
            data.BetterForCode(i) = 1; % Photo
        else
            data.BetterForCode(i) = 2; % Hybrid
        end
        
        % Clean Price (ensure numeric)
        if iscell(data.Price)
            data.Price(i) = str2double(data.Price{i});
        end
    end

    %% 2. BUILD USER INTERFACE
    % Main Figure
    fig = uifigure('Name', 'Smart Camera Recommender', 'Position', [100 100 500 400]);
    
    % Layout Grid
    grid = uigridlayout(fig, [6, 2]);
    grid.RowHeight = {'fit', 'fit', 'fit', 'fit', '1x', 'fit'};
    grid.ColumnWidth = {'1x', '1x'};
    
    % Title
    lblTitle = uilabel(grid);
    lblTitle.Text = "Camera Recommender System";
    lblTitle.FontSize = 20;
    lblTitle.FontWeight = 'bold';
    lblTitle.HorizontalAlignment = 'center';
    lblTitle.Layout.Row = 1;
    lblTitle.Layout.Column = [1 2];
    
    % Budget Input
    lblBudget = uilabel(grid);
    lblBudget.Text = "Max Budget (USD):";
    lblBudget.HorizontalAlignment = 'right';
    lblBudget.Layout.Row = 2;
    lblBudget.Layout.Column = 1;
    
    numBudget = uieditfield(grid, 'numeric');
    numBudget.Value = 2000; % Default
    numBudget.Layout.Row = 2;
    numBudget.Layout.Column = 2;
    
    % Usage Input
    lblUsage = uilabel(grid);
    lblUsage.Text = "Primary Use:";
    lblUsage.HorizontalAlignment = 'right';
    lblUsage.Layout.Row = 3;
    lblUsage.Layout.Column = 1;
    
    ddUsage = uidropdown(grid);
    ddUsage.Items = {'Photography', 'Hybrid (Photo/Video)', 'Video Production'};
    ddUsage.ItemsData = [1, 2, 3];
    ddUsage.Value = 2;
    ddUsage.Layout.Row = 3;
    ddUsage.Layout.Column = 2;
    
    % Recommend Button
    btnRun = uibutton(grid);
    btnRun.Text = "Find Camera";
    btnRun.FontWeight = 'bold';
    btnRun.BackgroundColor = [0.2 0.6 1];
    btnRun.FontColor = 'white';
    btnRun.Layout.Row = 4;
    btnRun.Layout.Column = [1 2];
    
    % Results Display
    txtResult = uitextarea(grid);
    txtResult.Editable = 'off';
    txtResult.FontSize = 14;
    txtResult.Layout.Row = 5;
    txtResult.Layout.Column = [1 2];
    
    % Initial text (using single quotes for cell array)
    txtResult.Value = {'Enter your preferences above and click "Find Camera".'};
    
    % Status Label
    lblStatus = uilabel(grid);
    lblStatus.Text = "Ready";
    lblStatus.FontColor = [0.5 0.5 0.5];
    lblStatus.Layout.Row = 6;
    lblStatus.Layout.Column = [1 2];

    %% 3. CALLBACK FUNCTION
    % Define what happens when button is clicked
    btnRun.ButtonPushedFcn = @(btn,event) recommendCamera(numBudget.Value, ddUsage.Value);

    % Recommendation Logic Function
    function recommendCamera(userBudget, userUse)
        lblStatus.Text = "Processing...";
        drawnow;
        
        % Filter data
        valid_cameras = data(data.Price <= userBudget & data.BetterForCode == userUse, :);
        
        if isempty(valid_cameras)
            % Use single quotes inside cell array
            txtResult.Value = { ...
                'No cameras found matching your criteria.', ...
                ' ', ...
                'Try increasing your budget.'};
            lblStatus.Text = "Done (No matches)";
        else
            % Scoring Algorithm
            rawRes = valid_cameras.MaxResolution;
            minRes = min(data.MaxResolution);
            rangeRes = max(data.MaxResolution) - minRes;
            if rangeRes == 0, rangeRes = 1; end
            normRes = (rawRes - minRes) / rangeRes;
            
            minPrice = min(data.Price);
            rangePrice = max(data.Price) - minPrice;
            if rangePrice == 0, rangePrice = 1; end
            
            % Fix: Added closing parenthesis and semicolon
            normPrice = 1 - ((valid_cameras.Price - minPrice) / rangePrice);
            
            final_scores = 0.6 * normRes + 0.4 * normPrice;
            
            [top_score, idx] = max(final_scores);
            rec = valid_cameras(idx, :);
            
            % Update GUI Output - Construct cell array of chars (single quotes)
            % Handle Model name carefully
            if iscell(rec.Model)
                modelName = rec.Model{1};
            else
                modelName = char(rec.Model(1));
            end
            
            resultStr = {
                '★ TOP RECOMMENDATION ★';
                '--------------------------------';
                sprintf('Model:       %s', modelName);
                sprintf('Price:       $%.2f', rec.Price);
                sprintf('Resolution:  %.1f MP', rec.MaxResolution);
                sprintf('Weight:      %.0f g', rec.Weight_g_);
                '--------------------------------';
                sprintf('Score:       %.2f / 1.0', top_score)
            };
            
            txtResult.Value = resultStr;
            lblStatus.Text = "Success";
        end
    end
end