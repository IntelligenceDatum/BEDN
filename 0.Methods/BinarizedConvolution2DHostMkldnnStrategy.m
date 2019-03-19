classdef BinarizedConvolution2DHostMkldnnStrategy < nnet.internal.cnn.layer.util.ExecutionStrategy
    % BinarizedConvolution2DHostMkldnnStrategy   Execution strategy for running the convolution
    % on the host using mkldnn. Note, currently only no dilation and single X supported.
    
    %   Copyright 2017-2018 The MathWorks, Inc.
    
    methods
        function [Z, memory] = forward(~, X, ...
                weights, bias, ...
                topPad, leftPad, ...
                bottomPad, rightPad, ...
                verticalStride, horizontalStride, ...
                ~, ~)
            
            weights= sign(weights);  %%%%%%%
            weights(weights==0)=1;
            
            
            if isa(X, 'single')
                Z = nnet.internal.cnnhost.convolveForward2D( ...
                    X, weights, ...
                    topPad, leftPad, ...
                    bottomPad, rightPad, ...
                    verticalStride, horizontalStride);
            else
                Z = nnet.internal.cnnhost.stridedConv( ...
                    X, weights, ...
                    topPad, leftPad, ...
                    bottomPad, rightPad, ...
                    verticalStride, horizontalStride);
            end
            
            Z = Z + bias;
            memory = [];
        end
        
        function [dX,dW] = backward( ~, ...
                X, weights, dZ, ...
                topPad, leftPad, ...
                bottomPad, rightPad, ...
                strideHeight, strideWidth, ...
                ~, ~)
            
            needsWeightGradients = nargout > 1;
            weights= sign(weights);  %%%%%%%
            weights(weights==0)=1;
            if isa(X, 'single')
                if needsWeightGradients
                    [dX, dW{1}] = nnet.internal.cnnhost.convolveBackward2D( ...
                        X, weights, dZ, ...
                        topPad, leftPad, ...
                        bottomPad, rightPad, ...
                        strideHeight, strideWidth);
                    dW{2} = nnet.internal.cnnhost.convolveBackwardBias2D(dZ);
                else
                    dX = nnet.internal.cnnhost.convolveBackward2D( ...
                        X, weights, dZ, ...
                        topPad, leftPad, ...
                        bottomPad, rightPad, ...
                        strideHeight, strideWidth);
                end
            else
                dX = nnet.internal.cnnhost.convolveBackwardData2D( ...
                    X, weights, dZ, ...
                    topPad, leftPad, ...
                    bottomPad, rightPad, ...
                    strideHeight, strideWidth);
                if needsWeightGradients
                    dW{1} = nnet.internal.cnnhost.convolveBackwardFilter2D( ...
                        X, weights, dZ, ...
                        topPad, leftPad, ...
                        bottomPad, rightPad, ...
                        strideHeight, strideWidth);
                    dW{2} = nnet.internal.cnnhost.convolveBackwardBias2D(dZ);
                end
            end
        end
    end
end