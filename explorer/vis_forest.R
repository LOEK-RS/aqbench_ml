
library(DiagrammeR)

onetree = treeInfo(rfmodel$finalModel, tree = 1)

onetree_connections = data.frame(from = c(onetree$nodeID, onetree$nodeID),
                                 to = c(onetree$leftChild, onetree$rightChild)) %>% na.omit()


onetree_nodes = data.frame(id = onetree$nodeID,
                           label = ifelse(!is.na(onetree$splitvarName),
                                          paste(onetree$splitvarName, " < ", round(onetree$splitval, 2)),
                                          round(onetree$prediction, 2)),
                           type = TRUE)



DiagrammeR::create_graph(nodes_df = onetree_nodes, edges_df = onetree_connections, directed = TRUE) %>%
    render_graph(layout = "tree")

onetree
