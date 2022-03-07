export default [
    {
        match: {
            predicate: {
                type: "uri",
                value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            },
            object: {
                type: "uri",
                value: "https://schema.org/SocialMediaPosting",
            },
        },
        callback: {
            url: "http://socialplatformmicroservice/posts/", method: "POST"
        },
        options: {
            resourceFormat: "v0.0.1",
            gracePeriod: 1000,
            ignoreFromSelf: true
        }
    }
]