# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=FALSE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
my_fun <-function(x, y){x*y}
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
columns <- c("clientid","currency",
             "CountOfAllInteractions","CountOfSessions", 
             "CountOfDirectSales", "CountOfAbandonments", 
             "CountOfOnsiteRecoveries", "CountOfEmails",
              "CountOfOpen", "CountOfClose", 
             "CountOfPositiveClose", "CountOfNegativeClose", "CountOfMissingClose", 
             "ValueOfDirectSales", "ValueOfAbandonments", "ValueOfOnsiteRecoveries", "ValueOfEmails")

setFields <- function(df) {
  for (i in 1:length(columns)) {
  column <- columns[i]
  temp <- df[[column]]
  df[[column]] <- NA
  if(i %in% 1:2) {
    df[[column]]<- as.factor(temp)
    
  df <- df %>%
    mutate(column = as.factor(column))
  }
  #for (i in 3:13) {
    #column <- Columns[i]
  #  x[[column]]<- as.integer(x[[column]])
  #}
  #TO DO error prone
  #for (i in 14:17) {
  #  column <- Columns[i]
  #  x[[column]]<- as.numeric(x[[column]])
  #}
  return(df)
  } 
}

reorder_size <- function(x) {
  factor(x, levels = names(sort(table(x))))
}

order_axis<-function(data, axis, column)
{
  # for interactivity with ggplot2
  arguments <- as.list(match.call())
  col <- eval(arguments$column, data)
  ax <- eval(arguments$axis, data)
  
  # evaluated factors
  a<-reorder(with(data, ax), 
             with(data, col))
  
  #new_data
  df<-cbind.data.frame(data)
  # define new var
  within(df, 
         do.call("<-",list(paste0(as.character(arguments$axis),"_o"), a)))
}

set_panel_size <- function(p=NULL, g=ggplotGrob(p), file=NULL, 
                           margin = unit(1,"mm"),
                           width=unit(4, "cm"), 
                           height=unit(4, "cm")){
  
  panels <- grep("panel", g$layout$name)
  panel_index_w<- unique(g$layout$l[panels])
  panel_index_h<- unique(g$layout$t[panels])
  nw <- length(panel_index_w)
  nh <- length(panel_index_h)
  
  if(getRversion() < "3.3.0"){
    
    # the following conversion is necessary
    # because there is no `[<-`.unit method
    # so promoting to unit.list allows standard list indexing
    g$widths <- grid:::unit.list(g$widths)
    g$heights <- grid:::unit.list(g$heights)
    
    g$widths[panel_index_w] <-  rep(list(width),  nw)
    g$heights[panel_index_h] <- rep(list(height), nh)
    
  } else {
    
    g$widths[panel_index_w] <-  rep(width,  nw)
    g$heights[panel_index_h] <- rep(height, nh)
    
  }
}

cor_list <- function(x) {
  L <- M <- cor(x)
  
  M[lower.tri(M, diag = TRUE)] <- NA
  M <- melt(M)
  names(M)[3] <- "points"
  
  L[upper.tri(L, diag = TRUE)] <- NA
  L <- melt(L)
  names(L)[3] <- "labels"
  
  merge(M, L)
}

normalize <- function(x) {
  # define a min-max normalize() function kNN algorithm
    return((x - min(x)) / (max(x) - min(x)))
}

le_count_feature <- function( percents, feature) {
  # calculates the counts for the given percentages for a given column 
  # set an empty dataframe for the result
  df = data.frame(tempcol = "")
  
  # creates the counts for the percentages
  df_percents <- quantile(feature, probs = percents)
  
  for (i in 1:length(percents)){
    varname <- paste(as.numeric(percents[i])*100)
    df[[varname]] <- sum(feature<=df_percents[i])
  }
  df <- select(df, -tempcol)
  
  #transform cols to rows 
  g_df <- gather(df, "percent", "count")
  return(g_df)    
}

le_range_feature <- function( percents, feature) {
  # calculates the range for the given percentages for a given column 
  # set an empty dataframe for the result
  df = data.frame(tempcol = "")
  
  # creates the counts for the
  df_percents <- quantile(feature, probs = percents)
  
  
  for (i in 1:length(percents)){
    if (i == 1){
      varname <- paste(as.numeric(percents[i])*100)
      df[[varname]] <- sum(feature<=df_percents[i])
    }
    else{
      varname <- paste(as.numeric(percents[i-1])*100, as.numeric(percents[i])*100, sep = "-")
      df[[varname]] <- sum(feature>df_percents[i-1] & feature<=df_percents[i])
    }
  }
  df <- select(df, -tempcol)
  #transform cols to rows 
  g_df <- gather(df, "range", "range_count")
  return(g_df)    
}

d_kpi_feature <- function( percents, feature) {
  #binds together the the percentage counts, range and value into a df
  
  # add "value" to df
  
  df_percents <- quantile(feature, probs = percents)
  df_percents <-data.frame(df_percents)
  g_df_percents <- gather(df_percents, "df_name", "value")
  g_df_percents <- select(g_df_percents, -df_name)
  
  
  d_kpi_result <- bind_cols(le_count_feature(percents, feature), 
                            le_range_feature(percents, feature),
                            g_df_percents)
  d_kpi_result$percent <- as.numeric(d_kpi_result$percent)
  return(d_kpi_result) 
  
}

plot_histogram <- function(v_data, v_feature, v_title, v_binwidth) {
  # histogram for a feature
  ggplot(v_data, aes(x = v_feature))+ 
    geom_histogram(binwidth=v_binwidth)+
    labs(title = paste(v_title),
         x = "", 
         y = "Nr of Sales")
}

plot_boxplot <- function(v_data, v_feature, v_title) {
  # boxplot for a feature 
  ggplot(d_rfm, aes(x = "", y = v_feature))+ 
    geom_boxplot()+
    labs(title = "",
         x = "", 
         y = v_title)
}

plot_summary <- function(v_data, v_feature, v_title, v_binwidth){
  # histogram, boxplot summary plot 
  # input: v-title - name of the feature
  p_h <- plot_histogram(d_rfm, v_feature, v_title, v_binwidth)
  p_b <- plot_boxplot(d_rfm, v_feature, v_title)
  multiplot(p_h, p_b)
}

d_summary <- function(v_data, v_feature){
  # overall summary in table format
  d_result <- v_data %>%
    select(everything()) %>% 
    summarise(mean =  round(mean(v_feature),0),
              sd = round(sd(v_feature), 0),
              min = round(min(v_feature),0), 
              max = round(max(v_feature),0),
              IQR = IQR(v_feature),
              median = median(v_feature),
              total = n()
    )
  d_result
}
ratio_plot <- function(l_percents, l_feature, v_title, v_x, v_y, v_caption,v_width, 
                       v_y_text_position){
  # ratio plot using d_input percentage counts 
  
  # input dataframe with percentage counts and range
  d_input <- d_kpi_feature(l_percents, l_feature)
  
  ggplot(d_input, aes(x = as.factor(percent), y = value, fill = value)) +
    geom_bar(stat='identity', position = "dodge", width = v_width)+
    geom_text(data=d_input, 
              aes(y= v_y_text_position,label = paste("total:", count, "range: ", range_count, "value<= ", round(value,2))),
              color='black', fontface = "bold")+
    labs( title = v_title, 
          x = v_x, 
          y = v_y, 
          caption = v_caption)+
    theme(plot.title = element_text(hjust = 0.5))+
    coord_flip()
}

naming_segments <- function(clusters, segments, nr_cluster){
  # clusters gets a human readable name 
  # Input: clustering model, human readable cluster names as a char list.
  # Constraint: the length(segments) should be equal to the cluster nr-s.
  # nr_cluster = lengths(segments)
  df_size <- data.frame(size = clusters$size)
  df_centers <- data.frame(clusters$centers)
  df_centers_rank <- data.frame(
    r_rank = min_rank(desc(df_centers$recency)),
    f_rank = min_rank(df_centers$frequency),
    m_rank = min_rank(df_centers$monetary))
  df_rank <- cbind(df_size, df_centers, df_centers_rank)
  # creating a column from rowid
  df_rank <- rowid_to_column(df_rank, "cluster")
  # creates a value from the ranking numbers
  df_rank <- add_column(df_rank, value = as.integer(paste0(df_rank$r_rank, df_rank$f_rank, df_rank$m_rank,sep = "")), .after = 2)
  df_rank <- add_column(df_rank, segment = "segment", .after = 1)
  df_rank <- df_rank[order(df_rank$value),]
  
  # rename first and last segment
  df_rank <- df_rank %>%
    select(everything()) %>%
    mutate(
      segment = case_when(
        m_rank == max(m_rank) ~ segments[nr_cluster],
        r_rank == min(r_rank) ~ segments[1],
        TRUE                      ~  "other"
      )
    )
  
  # rename subset of column values
  df_rank$segment[df_rank$segment == 'other'] = segments[2:(nr_cluster-1)]
  return(df_rank)
}

isempty <- function(dfs){
# verifies the emptiness of dfs vector. if so the chunk is not executed
  execute = TRUE
  for (i in dfs){
    if (is.numeric(nrow(dfs[i])) == 0){
      execute = FALSE
      
    }
    
  }
  return(execute)
}

row_number_faceting <- function(column){
# determines the nr of months for proper faceting
  nrofmonth <- 0
  nrofmonth <- as.numeric(length(unique(g_d_client_wdm_avg$Month)))
  if (nrofmonth <= 6){
    nrofrrow <-1
  }
  else{
    nrofrrow <-2
  }
}

weekday_month_recast <- function(df, col1, col2, max_nr_of_month){
  #spread df on multiple columns then unite two consecutive cols. max_nr_of_month allowed.  
  
  # Create quosure to be able to use 'select' inside function
  col1 <- enquo(col1)                    
  col2  <- enquo(col2) 
  
  # determine the nr_of_month based on unique 'Month'
  df <- df[order(df$Month), ]
  newcolnames <- tail(unique(df$Month), max_nr_of_month)
  uMonth <-length(newcolnames)
  
  df_result <- df %>%
    select(Weekday, Month, !!col1, !!col2)
  
  # max addmitted nr_of_month is gnrofmonth
  nr <- max_nr_of_month
  if (uMonth <= max_nr_of_month){
    nr <- uMonth
  }
  
  #TO DO in a more general manner
  #spread df on multiple columns then unite two consecutive cols
  if (nr == 1){
    df_result <- recast(df_result, Weekday ~ Month  + variable)%>%
      unite(col1, 2:3, sep = "|", remove = TRUE)
  }
  if (nr == 2){
    df_result <- recast(df_result, Weekday ~ Month  + variable)%>%
      unite(col1, 2:3, sep = "|", remove = TRUE)%>%
      unite(col2, 3:4, sep = "|", remove = TRUE)
  } 
  if (nr == 3){
    df_result <- recast(df_result, Weekday ~ Month  + variable)%>%
      unite(col1, 2:3, sep = "|", remove = TRUE)%>%
      unite(col2, 3:4, sep = "|", remove = TRUE)%>%
      unite(col3, 4:5, sep = "|", remove = TRUE)
  }
  if (nr == 4){
    df_result <- recast(df_result, Weekday ~ Month  + variable)%>%
      unite(col1, 2:3, sep = "|", remove = TRUE)%>%
      unite(col2, 3:4, sep = "|", remove = TRUE)%>%
      unite(col3, 4:5, sep = "|", remove = TRUE)%>%
      unite(col3, 5:6, sep = "|", remove = TRUE)
  } 
  
  
  #renaming back the column to 'Month' names
  colnames(df_result) <- append(as.character(c("")), as.character(newcolnames))
  return(df_result)
}
