import { Antagonist, Category } from '../base';

const EarthGovAgent: Antagonist = {
  key: 'earthgovagent',
  name: 'Earth Government Agent',
  description: [
    `
      The Geometer of Blood, Nar-Sie, has sent a number of her followers to
      Space Station 13. As a cultist, you have an abundance of cult magics at
      your disposal, something for all situations. You must work with your
      brethren to summon an avatar of your eldritch goddess!
    `,

    `
      Armed with blood magic, convert crew members to the Blood Cult, sacrifice
      those who get in the way, and summon Nar-Sie.
    `,
  ],
  category: Category.Roundstart,
};

export default EarthGovAgent;
