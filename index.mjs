// handler function to redirect to index.html if the request is for a directory
const hasExtenston = /(.+)\.[a-zA-Z0-9]{2,5}$/;

export const handler = async (event) => {
  const request = event.Records[0].cf.request;

  const url = request.uri;

  if (url && url.endsWith("/")) {
    request.uri += "index.html";
  } else if (url && !url.match(hasExtenston)) {
    request.uri += "/index.html";
  }
  return request;
};
