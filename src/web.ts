import { WebPlugin } from '@capacitor/core';
import {
  CapacitorSQLitePlugin,
  capEchoOptions,
  capSQLiteOptions,
  capSQLiteExecuteOptions,
  capSQLiteSetOptions,
  capSQLiteRunOptions,
  capSQLiteQueryOptions,
  capSQLiteImportOptions,
  capSQLiteExportOptions,
  capSQLiteSyncDateOptions,
  capSQLiteUpgradeOptions,
  capSQLiteTableOptions,
  capSQLitePathOptions,
  capEchoResult,
  capSQLiteResult,
  capSQLiteChanges,
  capSQLiteValues,
  capSQLiteJson,
  capSQLiteSyncDate,
} from './definitions';

export class CapacitorSQLiteWeb
  extends WebPlugin
  implements CapacitorSQLitePlugin {
  constructor() {
    super({
      name: 'CapacitorSQLite',
      platforms: ['web'],
    });
  }

  async echo(options: capEchoOptions): Promise<capEchoResult> {
    console.log('ECHO in Web plugin', options);
    return options;
  }
  async createConnection(options: capSQLiteOptions): Promise<capSQLiteResult> {
    console.log('createConnection', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async open(options: capSQLiteOptions): Promise<capSQLiteResult> {
    console.log('open', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async closeConnection(options: capSQLiteOptions): Promise<capSQLiteResult> {
    console.log('closeConnection', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async close(options: capSQLiteOptions): Promise<capSQLiteResult> {
    console.log('close', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async execute(options: capSQLiteExecuteOptions): Promise<capSQLiteChanges> {
    console.log('execute', options);
    return Promise.resolve({
      changes: { changes: -1 },
      message: `Not implemented on Web Platform`,
    });
  }
  async executeSet(options: capSQLiteSetOptions): Promise<capSQLiteChanges> {
    console.log('execute', options);
    return Promise.resolve({
      changes: { changes: -1 },
      message: `Not implemented on Web Platform`,
    });
  }
  async run(options: capSQLiteRunOptions): Promise<capSQLiteChanges> {
    console.log('run', options);
    return Promise.resolve({
      changes: { changes: -1 },
      message: `Not implemented on Web Platform`,
    });
  }
  async query(options: capSQLiteQueryOptions): Promise<capSQLiteValues> {
    console.log('query', options);
    return Promise.resolve({
      values: [],
      message: `Not implemented on Web Platform`,
    });
  }
  async isDBExists(options: capSQLiteOptions): Promise<capSQLiteResult> {
    console.log('in Web isDBExists', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async isDBOpen(options: capSQLiteOptions): Promise<capSQLiteResult> {
    console.log('in Web isDBOpen', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async isDatabase(options: capSQLiteOptions): Promise<capSQLiteResult> {
    console.log('in Web isDatabase', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }

  async isTableExists(
    options: capSQLiteTableOptions,
  ): Promise<capSQLiteResult> {
    console.log('in Web isTableExists', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async deleteDatabase(options: capSQLiteOptions): Promise<capSQLiteResult> {
    console.log('deleteDatabase', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async isJsonValid(options: capSQLiteImportOptions): Promise<capSQLiteResult> {
    console.log('isJsonValid', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }

  async importFromJson(
    options: capSQLiteImportOptions,
  ): Promise<capSQLiteChanges> {
    console.log('importFromJson', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async exportToJson(options: capSQLiteExportOptions): Promise<capSQLiteJson> {
    console.log('exportToJson', options);
    return Promise.resolve({
      message: `Not implemented on Web Platform`,
    });
  }
  async createSyncTable(options: capSQLiteOptions): Promise<capSQLiteChanges> {
    console.log('createSyncTable', options);
    return Promise.resolve({
      changes: { changes: -1 },
      message: `Not implemented on Web Platform`,
    });
  }
  async setSyncDate(
    options: capSQLiteSyncDateOptions,
  ): Promise<capSQLiteResult> {
    console.log('setSyncDate', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async getSyncDate(options: capSQLiteOptions): Promise<capSQLiteSyncDate> {
    console.log('getSyncDate', options);
    return Promise.resolve({
      syncDate: 0,
      message: `Not implemented on Web Platform`,
    });
  }
  async addUpgradeStatement(
    options: capSQLiteUpgradeOptions,
  ): Promise<capSQLiteResult> {
    console.log('addUpgradeStatement', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async copyFromAssets(): Promise<capSQLiteResult> {
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async getDatabaseList(): Promise<capSQLiteValues> {
    return Promise.resolve({
      values: [],
      message: `Not implemented on Web Platform`,
    });
  }
  async addSQLiteSuffix(
    options: capSQLitePathOptions,
  ): Promise<capSQLiteResult> {
    console.log('addSQLiteSuffix', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
  async deleteOldDatabases(
    options: capSQLitePathOptions,
  ): Promise<capSQLiteResult> {
    console.log('deleteOldDatabases', options);
    return Promise.resolve({
      result: false,
      message: `Not implemented on Web Platform`,
    });
  }
}

const CapacitorSQLite = new CapacitorSQLiteWeb();

export { CapacitorSQLite };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(CapacitorSQLite);
