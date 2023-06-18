function [region_plot, d_plots, d_avg_plots] = generate_region_plots(interact_axes,display_axes,win_cen,d,d_avg,region_loc)
    % Plot region
    dim1 = region_loc(3)-region_loc(1);
    dim2 = region_loc(4)-region_loc(2);
    hold(interact_axes,"on");
    region_plot = rectangle(interact_axes,'Position',[region_loc(2),region_loc(1),dim2,dim1],'EdgeColor',[1 0.8 0.4],'LineWidth',2);
    region_plot.Visible = "off";
    hold(interact_axes,"off");

    % Check if too many plots (to avoid lag), if too many, reduce d to 100 windows only
    if size(d,3)>100
        x = mean(sum(d.^2,2),1); % calculate average displacement magnitude for each window
        [~,ind] = maxk(x,100); % get index for 100 largest displacements
        ind = squeeze(ind); % fix dimensions
        d = d(:,:,ind);
        win_cen = win_cen(ind,:);
    end

    % Iterate through each window, plot displacement vectors
    d_plots = [];
    d_avg_plots = [];
    hold(display_axes,"on");
    for i = 1:size(win_cen,1)
        new_plots = [];
        curr_cen = win_cen(i,:);
        for j = 1:size(d,1)
            % Plot quiver for each displacement vector
            d_plot = quiver(display_axes, ...
                curr_cen(2),curr_cen(1),d(j,2,i),d(j,1,i), ...
                0,"LineWidth",1.5,"Color",[0.4 0.8 1]);
            new_plots = cat(1,new_plots,d_plot);
            d_plot.Visible = 'off';
            % Update new centerpoint for displacement
            curr_cen = curr_cen+d(j,:,i);
        end
        % Add plots to d_plots
        d_plots = cat(2,d_plots,new_plots);
        switch i
            case round(0.1*size(win_cen,1))
                fprintf("0.1 of plots complete\n");
            case round(0.25*size(win_cen,1))
                fprintf("0.25 of plots complete\n");
            case round(0.5*size(win_cen,1))
                fprintf("0.5 of plots complete\n");
            case round(0.25*size(win_cen,1))
                fprintf("0.75 of plots complete\n");
        end
    end
    fprintf("All displacement plots complete\n");

    % Iterate through each frame, plot average displacement
    curr_cen = [round((region_loc(1)+region_loc(3))/2) round((region_loc(2)+region_loc(4))/2)];
    for i = 1:size(d_avg,1)
        % Plot quiver for each average displacement vector
        new_d_avg_plot = quiver(display_axes, ...
            curr_cen(2),curr_cen(1),d_avg(i,2),d_avg(i,1), ...
            0,"LineWidth",2,"Color",[1 0.8 0.4]);
        new_d_avg_plot.Visible = 'off';
        % Add new plot to array
        d_avg_plots = cat(1,d_avg_plots,new_d_avg_plot);
        % Update new centerpoint for displacement
        curr_cen = curr_cen+d_avg(i,:);
    end
    hold(display_axes,"off");
end