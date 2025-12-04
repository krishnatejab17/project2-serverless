exports.handler = async (event) => {
  return {
    statusCode: 200,
    headers: {
      "Content-Type": "text/plain"
    },
    body: "Hello from Lambda CI/CD 🚀"
  };
};
