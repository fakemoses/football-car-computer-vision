## RANSAC (Random Sample Consensus)

**Problem:** 
- Dealing with Outliers!
	- eg. noise, unwanted points
	- resulting in invalid matches in model
	- if outliers < 50%, -> use RANSAC

### Algorithm
1. Randomly chose **s** samples.
	- s is the minimum samples to fit a model.
	- Homography, s = 4
	- Linear Line, s = 2
2. Fit the model to the randomly chosen samples.
3. Count the number **M** of inliers that fit the model within error 
4. Repeat 1-3 **N** times
5. Choose the model that has the largest inliers