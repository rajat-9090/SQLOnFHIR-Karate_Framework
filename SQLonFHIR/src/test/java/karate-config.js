function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
    ApiKeyValue: 'ApiKey AvG1cZHyFjLB3RqiDKproQMp9yxwtFiwqiAdreKHecQyYKhwxJpA2Xtklp1l72gdT95rr3U6Pg8WcDokHk3wimbsXRKa8Lowu0Eh5b8ZpXv584h2ku6CJsbD7NOmPj0c',
    host: 'https://sqlonfhir-sqlonfhir.fhir.azurehealthcareapis.com',

  }
  if (env == 'dev') {
    // customize
    // e.g. config.foo = 'bar';
  } else if (env == 'e2e') {
    // customize
  }

  return config;
}