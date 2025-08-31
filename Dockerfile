# Create a container image from nginx:stable
FROM nginx:stable

# Update and upgrade the exisiting installed packages, and 
# install any additional required packages.
RUN apt-get update && \
    apt-get upgrade -y
    
# Expose port 80 on the deployed container to allow access.
# When deployed in a kubernetes cluster your security group (if setup) will need 
# to allow traffic to port 80.
EXPOSE 80

# CMD instruction to start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]